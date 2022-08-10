#!/usr/bin/env Rscript
#
#
# Script: MonkeyPox_sigmoid.r
#
# Download monkeypox data from Our World in Data 
# and draw diagrams for selected locations.
#
# Regression analysis 

# Fit data against an sigmoid 

# Stand: 2022-08-10
#
# ( c ) 2022 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de

MyScriptName <- "MonkeyPox_sigmoid"

require( data.table )
library( tidyverse )
# library( REST )
library( grid )
library( gridExtra )
library( gtable )
library( lubridate )
library( readODS )
library( ggplot2 )
library( ggrepel )
library( viridis )
library( hrbrthemes )
library( scales )
library( ragg )

# library( extrafont )
# extrafont::loadfonts()

# Set Working directory to git root

if ( rstudioapi::isAvailable() ){
 
 # When executed in RStudio
 SD <- unlist( str_split( dirname( rstudioapi::getSourceEditorContext()$path ),'/' ) )
 
} else {
 
 # When executi on command line 
 SD = ( function() return( if( length( sys.parents() ) == 1 ) getwd() else dirname( sys.frame( 1 )$ofile ) ) )()
 SD <- unlist( str_split( SD,'/' ) )
 
}

WD <- paste( SD[1:( length( SD )-1 )],collapse = '/' )

setwd( WD )

source( "R/lib/myfunctions.r" )
source( "R/lib/mytheme.r" )
source( "R/lib/sql.r" )

outdir <- 'png/mpx/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

citation <- "© 2022 by Thomas Arend\nQuelle: Our World in Data"

options( 
 digits = 7
 , scipen = 7
 , Outdec = "."
 , max.print = 3000
 )

today <- Sys.Date()
PWeek <- PandemieWoche( today ) - 1
heute <- format( today, "%d %b %Y" )

Fexp <- function ( x , a = 0, b = 1) {
  
  return( exp( a + b * ( as.numeric(x) -  as.numeric(as.Date('2022-01-01') )) ))
  
}

Fsig <- function ( x , a = 0, b = 1, N = 1) {
  
  return( N * 1/( 1 + exp( a + b * ( as.numeric(x) -  as.numeric(as.Date('2022-01-01') )) )) )
  
}

SQL = 'select * from monkeypox as M join locations as L on L.location = M.location;'

if ( ! exists( "MPX" ) ) {
 
  MPX <- RunSQL(SQL)
}

MPX$date <- as.Date( MPX$date )
MPX$Tag <- yday(MPX$date)

CI = 0.95

Locations <- RunSQL('select distinct location,max(total_cases) as cases from monkeypox group by location having cases > 1000;')

for ( l in Locations$location ) {

  N <- (MPX %>% filter (location == l))$PopTotal[1]
  
  ra <- lm( data = MPX %>% filter ( Tag >= 125 & location == l & total_cases > 100 & ! is.na(total_cases) ), formula = log( N / total_cases - 1 ) ~ Tag )
#  ra <- lm( data = MPX %>% filter ( Tag >= 125 & location == l & total_cases > 100 & ! is.na(total_cases)), formula = log(total_cases) ~ Tag )
  ci <- confint(ra,level = CI)
  
  a <- c( ci[1,1], ra$coefficients[1] , ci[1,2])
  b <- c( ci[2,1], ra$coefficients[2] , ci[2,2])
  
  print(a)
  print(b)

  R2 <- summary(ra)$adj.r.squared

        
  MPX %>% filter (Tag >= 125 & location == l) %>% ggplot(
  ) +
    geom_point( aes( x = date, y = total_cases, colour = 'Fälle' ) ) +
    geom_function( mapping = aes(colour = 'lower 95 %'),fun = Fsig, args = list( a = a[2], b = b[1], N = N ) ) +
    geom_function( mapping = aes(colour = 'mean'), fun = Fsig, args = list( a = a[2], b = b[2], N = N ) ) +
    geom_function( mapping = aes(colour = 'upper 95 %'), fun = Fsig, args = list( a = a[2], b = b[3], N = N ) ) +
    scale_x_date( date_labels = '%Y-%b', date_breaks = 'months' ) +
    scale_y_continuous(  labels = function ( x ) format( x, big.mark = ".", decimal.mark = ',', scientific = FALSE ) ) +
    theme_ipsum() +
    theme( 
      axis.text.x = element_text(angle = 90)
    )  +
    labs(  title = paste( 'Affenpocken-Fallzahlen', l )
           , subtitle = paste( 'R² = ', round(R2,4), 'Stand:', heute )
           , x = 'Datum'
           , y = 'Summe Fälle' 
           , colour = 'Legende' ) -> p1
  
  ggsave(  filename = paste( outdir, MyScriptName, '_Sigs_', l , '.png', sep = '' )
           , plot = p1
           , path = WD
           , device = 'png'
           , bg = "white"
           , width = 29.7
           , height = 21
           , units = "cm"
           , dpi = 300 
  )
  
  p1 <- p1 +
    expand_limits( x = as.Date('2023-06-30') )

  ggsave(  filename = paste( outdir, MyScriptName, '_Sigl_', l , '.png', sep = '' )
           , plot = p1
           , path = WD
           , device = 'png'
           , bg = "white"
           , width = 29.7
           , height = 21
           , units = "cm"
           , dpi = 300
  )

}