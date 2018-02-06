#' @title
#' Query the Pagespeed API for a given page
#'
#' @param ps_url
#' The URL which you'd like to analyse
#' @param key
#' The API key (not required) which you'll be using to query the Google API
#' @param filter_tpr
#'	Indicates if third party resources should be filtered out before PageSpeed analysis. (boolean)
#' @param locale
#' The locale used to localize formatted results (string)
#' @param rule
#' A PageSpeed rule to run; if none are given, all rules are run (string)
#' @param screenshot
#' Indicates if binary data containing a screenshot should be included (boolean)
#' @param snapshots
#' Indicates if binary data containing snapshot images should be included (boolean)
#' @param strategy
#' 	The analysis strategy (desktop or mobile) to use, and desktop is the default (string)
#' @param utm_campaign
#' Campaign name for analytics. (string)
#' @param utm_source
#' 	Campaign source for analytics. (string)
#' @param fields
#' Selector specifying which fields to include in a partial response.
#'
#' @return
#' Returns a data frame containing key pagespeed insights for the given request
#'
#' @export
#'
#' @examples
#' jaguar <- get_pagespeed(ps_url = "http://www.jaguar.co.uk", key = "my_key", strategy = "desktop")
#'
#' See also metrics reference at https://developers.google.com/web/tools/chrome-user-experience-report/#metrics
get_pagespeed <- function(
  ps_url = NULL,
  key = NULL,
  filter_tpr = NULL,
  locale = NULL,
  rule = NULL,
  screenshot = NULL,
  snapshots = NULL,
  strategy = NULL,
  utm_campaign = NULL,
  utm_source = NULL,
  fields = NULL
) {
  req <- httr::GET(url = "https://www.googleapis.com/pagespeedonline/v4/runPagespeed",
                   query = list(  url = ps_url,
                                  key = key,
                                  filter_tpr = filter_tpr,
                                  locale = locale,
                                  rule = rule,
                                  screenshot = screenshot,
                                  snapshots = snapshots,
                                  strategy = strategy,
                                  utm_campaign = utm_campaign,
                                  utm_source = utm_source,
                                  fields = fields))
  httr::stop_for_status(req)
  if (httr::http_type(req) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  # Parse out our values
  con <- httr::content(req, "text")
  parsed <- jsonlite::fromJSON(con)

  # Extract all values
  single_results <- data.frame(title = ifelse(is.null(parsed$title), "Not available", parsed$title),
                               url = ifelse(is.null(parsed$loadingExperience$initial_url), "Not available", parsed$loadingExperience$initial_url),
                               speed_score = ifelse(is.null(parsed$ruleGroups$SPEED$score), "Not available", parsed$ruleGroups$SPEED$score),
                               overall_category = ifelse(is.null(parsed$loadingExperience$overall_category), "Not available", parsed$loadingExperience$overall_category))
  page_stats_df <- as.data.frame(parsed$pageStats)
  FCP <- data.frame(fcp_median = ifelse(is.null(parsed$loadingExperience$metrics$FIRST_CONTENTFUL_PAINT_MS$median), "Not available", parsed$loadingExperience$metrics$FIRST_CONTENTFUL_PAINT_MS$median),
                    fcp_category = ifelse(is.null(parsed$loadingExperience$metrics$FIRST_CONTENTFUL_PAINT_MS$category), "Not available", parsed$loadingExperience$metrics$FIRST_CONTENTFUL_PAINT_MS$category))
  DCL <- data.frame(dcl_median = ifelse(is.null(parsed$loadingExperience$metrics$DOM_CONTENT_LOADED_EVENT_FIRED_MS$median), "Not available", parsed$loadingExperience$metrics$DOM_CONTENT_LOADED_EVENT_FIRED_MS$median),
                    dcl_category = ifelse(is.null(parsed$loadingExperience$metrics$DOM_CONTENT_LOADED_EVENT_FIRED_MS$category), "Not available", parsed$loadingExperience$metrics$DOM_CONTENT_LOADED_EVENT_FIRED_MS$category))
  full_results <- cbind(single_results, page_stats_df, FCP, DCL)
  full_results
}

