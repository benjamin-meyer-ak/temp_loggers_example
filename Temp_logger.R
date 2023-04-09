# clear up everything
rm(list=ls()) # clearing environment
graphics.off() # clearing graphic device
cat("\014") # clearing console


# load required packages
library(magrittr) # object modifications in place
library(tidyverse) # smart data manipulation
library(lubridate) # smart dates manipulation
library(qdapRegex) # smart string manipulation

# roll over the csv files in the "input" folder pulling in data
csvNames <- sort(list.files("input/csv/", full.names = TRUE))
allData <- list()
colTypes <- cols("i", "c", "d", "?", "_", "_", "_")
for (i in seq_along(csvNames)) {
  #   - sometimes when reading from csv it is convenient to specify
  #     the column types to avoid warnings and prevent erros
  #   - R has the following convention:
  #       - i: integer
  #       - c: character
  #       - d: double
  #       - ?: unknown, let read_csv guess
  #       - _: ignore this column
  tmpData <- read_csv(csvNames[i], col_types = colTypes, skip = 1) %>%
    select(starts_with(c("Date","Temp")))
  colnames(tmpData) <- c("date_time","temp_C")
  tmpData %<>% transform(date_time = mdy_hms(date_time))
  tmpData$logger_id <- ex_between(csvNames[i], "csv/", ".csv")
  allData[[i]] <- tmpData
}

# merge all the datasets into one data frame
allData <- do.call(rbind, allData)

# plot one sensor at a time
logger <- "21444843"
tarData <- allData %>% filter(logger_id == logger)
p <- ggplot(tarData, aes(date_time,temp_C)) + geom_point()
ggplotly(p)

# read in file of visually identified flagged data
flagData <- read.csv("input/temp_logger_flagged_data.csv", sep = ",") %>%
  select(-notes, -X) %>% drop_na() %>%
  transform(date_time_start = mdy_hm(date_time_start),
            date_time_stop = mdy_hm(date_time_stop)) %>%
  transform(logger_id = as.character(logger_id))

# mark flagged events in the full record
# ------------------------------------------------------------------------------
# all starts usable
allData$useData <- 1

# then we roll over the flags identifying matching rows in the full record
flagPivs <- unique(unlist(apply(flagData, 1, function(v) {
  which(allData$logger_id == v[1] & allData$date_time >= as_datetime(v[2]) & allData$date_time <= as_datetime(v[3]))
})))

# finally, we mark all useData values of bad events as 0
allData$useData[flagPivs] <- 0
# ------------------------------------------------------------------------------




# This is a test just to verify the result is what we expected
# these lines can be removed later if you want!
#   - let's first check that all bad events are properly tagged
#     we can select and ctrl+enter the next two sentences multiple times
#     the result is always zero as useData in bad cases SHOULD be always zero
rnd <- runif(1, 1, nrow(flagData))
sum(allData$useData[allData$logger_id == flagData$logger_id[rnd] &
                      allData$date_time >= flagData$date_time_start[rnd] &
                      allData$date_time <= flagData$date_time_stop[rnd]])
#   - let's now check everything apart from those cases are one
#     here we check if any of the useData 1 cases lie in a flagged period of a logger
any(apply(allData[allData$useData == 1,], 1, function(v) {
  any(v[4] == flagData$logger_id &
        as_datetime(unlist(v[1])) >= flagData$date_time_start &
        as_datetime(unlist(v[1])) <= flagData$date_time_stop)
}))
