#' @title get KNMI climate day data.
#'
#' @description
#' \code{get_climate_data_api} retrieves KNMI data through the KNMI-API.
#'
#' @details
#' This function retrieves raw climate data collected by the official KNMI measurement stations for a specific station
#' and/or date-range. It uses the, somewhat slower, KNMI-API to collect the data.
#' The function \code{\link{get_climate_data_zip}} in this package is optimized to collect data for larger date-ranges (e.g.
#' for > 10 years), but is less flexible with combinations of all or specific stations and date ranges.
#'
#' You can specify a specific station or get data from all the stations at once (the default).
#' When the from and to date parameters are not proviced, all measurements for the current year are returned. Otherwise
#' the data is subsetted to the given interval.
#'
#' The original KNMI API is described on the web-page \href{https://www.knmi.nl/kennis-en-datacentrum/achtergrond/data-ophalen-vanuit-een-script}{collecting data through a script}.
#'
#' Note: this function only works for the land-based measurement stations, so not for the stations in the North Sea, as
#'       the API does not expose these.
#'
#' @param stationID ID for the KNMI measurement station. The available stations can be retrieved with the function 'getStations()'. Defaults to "all". . Note: a string of characters in the format 'iii'.
#' @param from startdate for the time-window. Defaults to the start of the current year. Note: a string of characters in the format 'yyyymmdd'.
#' @param to enddate for the time-window. Defaults to yesterday. Note: a string of characters in the format 'yyyymmdd'.
#' @return a data frame.
#' @format The returned data frame contains the following columns:
#' \itemize{
#'   \item STN      = ID of measurementstation;
#'   \item YYYYMMDD = Datum (YYYY=jaar MM=maand DD=dag);
#'   \item DDVEC	Vectorgemiddelde windrichting in graden (360=noord, 90=oost, 180=zuid, 270=west, 0=windstil/variabel). Zie \url{http://www.knmi.nl/kennis-en-datacentrum/achtergrond/klimatologische-brochures-en-boeken};
#'   \item FHVEC	Vectorgemiddelde windsnelheid (in 0.1 m/s). Zie \url{http://www.knmi.nl/kennis-en-datacentrum/achtergrond/klimatologische-brochures-en-boeken};
#'   \item FG	Etmaalgemiddelde windsnelheid (in 0.1 m/s);
#'   \item FHX	Hoogste uurgemiddelde windsnelheid (in 0.1 m/s);
#'   \item FHXH	Uurvak waarin FHX is gemeten;
#'   \item FHN	Laagste uurgemiddelde windsnelheid (in 0.1 m/s);
#'   \item FHNH	Uurvak waarin FHN is gemeten;
#'   \item FXX	Hoogste windstoot (in 0.1 m/s);
#'   \item FXXH	Uurvak waarin FXX is gemeten;
#'   \item TG	Etmaalgemiddelde temperatuur (in 0.1 graden Celsius);
#'   \item TN	Minimum temperatuur (in 0.1 graden Celsius);
#'   \item TNH	Uurvak waarin TN is gemeten;
#'   \item TX	Maximum temperatuur (in 0.1 graden Celsius);
#'   \item TXH	Uurvak waarin TX is gemeten;
#'   \item T10N	Minimum temperatuur op 10 cm hoogte (in 0.1 graden Celsius);
#'   \item T10NH	6-uurs tijdvak waarin T10N is gemeten;
#'   \item SQ	Zonneschijnduur (in 0.1 uur) berekend uit de globale straling (-1 voor <0.05 uur);
#'   \item SP	Percentage van de langst mogelijke zonneschijnduur;
#'   \item Q	Globale straling (in J/cm2);
#'   \item DR	Duur van de neerslag (in 0.1 uur);
#'   \item RH	Etmaalsom van de neerslag (in 0.1 mm) (-1 voor <0.05 mm);
#'   \item RHX	Hoogste uursom van de neerslag (in 0.1 mm) (-1 voor <0.05 mm);
#'   \item RHXH	Uurvak waarin RHX is gemeten;
#'   \item EV24	Referentiegewasverdamping (Makkink) (in 0.1 mm);
#'   \item PG	Etmaalgemiddelde luchtdruk herleid tot zeeniveau (in 0.1 hPa) berekend uit 24 uurwaarden;
#'   \item PX	Hoogste uurwaarde van de luchtdruk herleid tot zeeniveau (in 0.1 hPa);
#'   \item PXH	Uurvak waarin PX is gemeten;
#'   \item PN	Laagste uurwaarde van de luchtdruk herleid tot zeeniveau (in 0.1 hPa);
#'   \item PNH	Uurvak waarin PN is gemeten;
#'   \item VVN	Minimum opgetreden zicht;
#'   \item VVNH	Uurvak waarin VVN is gemeten;
#'   \item VVX	Maximum opgetreden zicht;
#'   \item VVXH	Uurvak waarin VVX is gemeten;
#'   \item NG	Etmaalgemiddelde bewolking (bedekkingsgraad van de bovenlucht in achtsten, 9=bovenlucht onzichtbaar);
#'   \item UG	Etmaalgemiddelde relatieve vochtigheid (in procenten);
#'   \item UX	Maximale relatieve vochtigheid (in procenten);
#'   \item UXH	Uurvak waarin UX is gemeten;
#'   \item UN	Minimale relatieve vochtigheid (in procenten);
#'   \item UNH	Uurvak waarin UN is gemeten;
#' }
#' @keywords historic weather data
#' @export
get_climate_data_api <- function(stationID = "ALL",
                                 from = paste(format(Sys.Date(), format = "%Y"), "0101", sep = ""),
                                 to = format(Sys.Date()-1, format = "%Y%m%d")) {

   baseURL <- "http://projects.knmi.nl/klimatologie/daggegevens/getdata_dag.cgi"
   params <- "ALL"
   link <- paste(baseURL, "?start=", from, "&end=", to, "&stns=", stationID,"&", params, sep = "")
   data <- data.frame(read.csv(link, header = FALSE, sep = ",", comment.char = "#"))

   colnames(data) <- c("STN","YYYYMMDD","DDVEC","FHVEC","FG","FHX","FHXH","FHN","FHNH","FXX","FXXH","TG","TN","TNH","TX","TXH","T10N","T10NH","SQ","SP","Q","DR","RH","RHX","RHXH","EV24","PG","PX","PXH","PN","PNH","VVN","VVNH","VVX","VVXH","NG","UG","UX","UXH","UN","UNH")

   return(data)
}
