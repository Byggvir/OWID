#!/usr/bin/env Rscript
#
# Script: MonkeyPoxWeek.r
#
# Our World in Data (OWID) 
# Draw diagrams for selected locations.
#
# Weekly cases

# Stand: 2022-08-10
#
# ( c ) 2022 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "MonkeyPoxWeek"

require( data.table )
library( tidyverse )
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

Fexp <- function ( x , a = 0, b = 1, N = 1) {
  
  return( exp( a + b * ( as.numeric(x) -  as.numeric(as.Date('2022-01-01') )) ))
  
}

Fsig <- function ( x , a = 0, b = 1, N = 1) {
  
  return( N * 1/( 1 + exp( a + b * ( as.numeric(x) -  as.numeric(as.Date('2022-01-01') )) )) )
  
}

SQL = 'select L.location, weekofyear(`date`) as kw, sum(new_cases) as cases from monkeypox as M join locations as L on L.location = M.location group by L.location,kw;'

if ( ! exists( "MPXweek" ) ) {
  
   MPXweek <- RunSQL(SQL)
}


Locations <- RunSQL('select distinct location,max(total_cases) as cases from monkeypox group by location having cases > 1000;')

wmin = min(MPXweek$kw)
wmax = max(MPXweek$kw)

for ( l in Locations$location ) {
  
  MPXweek %>% filter ( location == l ) %>% ggplot(  ) +
    geom_bar( aes( x = kw, y = cases ), stat="identity", position = position_dodge() , alpha = 0.5) +
    geom_text(aes( x = kw , y = cases, label = cases )) +
    scale_x_continuous( breaks = wmin:wmax  ) +
    scale_y_continuous(  labels = function ( x ) format( x, big.mark = ".", decimal.mark = ',', scientific = FALSE ) ) +
    theme_ipsum() +
    theme( 
      axis.text.x = element_text(angle = 90)
    )  +
    labs(  title = paste( 'Affenpocken-Fallzahlen', l )
           , subtitle = paste( 'Neue Fälle pro Kalenderwoche' )
           , x = 'Kalenderwoche'
           , y = 'Neue Fälle' 
           , colour = 'Legende' ) -> p1
  
  ggsave(  filename = paste( outdir, MyScriptName, '_week_', l , '.png', sep = '' )
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