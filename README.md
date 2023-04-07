# temp_loggers_example

**Work Description**

I am working with a large volume of data from water temperature loggers. Each logger records a time temperature observation every quarter-hour, and is saved as a csv file.

Each logger time series needs to be inspected and have parts of the time series removed (e.g., if the logger is exposed to air instead of water). I would like to do this task in an R script rather than manually altering the csv files.

I would like to have an R script that can perform the following tasks:

1.  Use a function to import multiple csv files from the same directory, and collate them all into a single dataframe.

    -   It is important that the csv files remain unaltered prior to import, and that they do not require manual "cleaning" prior to import (i.e. manual deletion of rows or columns)

2.  Use a separate data table with defined time periods of "flagged data" to identify flagged data in each time series

    -   For example, the "flagged data" table would identify the time periods

        -   from "2022-08-01 05:15:00" to "2022-08-05 05:30:00"

        -   from "2022-09-02 05:30:00" to "2022-09-05 06:45:15"

            -   for logger #20012591

    -    The script would mutate a new "flagged_data" column to identify flagged data from these time periods

    -   Multiple time periods would be identified as flagged data, from multiple loggers

I have placed three example csv files in the "input" folder of this repository. I have also placed an example "temp_logger_flagged_data.csv" file in the same folder.

If possible, it is my preference that the script is based around tidyverse functions when possible, as my colleagues are more familiar with this language. If it is not possible to do this, that is OK.

It is my preference that we accomplish this task through GitHub. If hired, please make a "pull request" to this example repository.

Thank you!



## Example Time series (for one logger)

```{r}
library(tidyverse)
library(magrittr)

# read in csv
temp_dat <- read_csv("input/csv/21235341.csv", skip = 1) %>%
  select(starts_with(c("Date","Temp"))) 
colnames(temp_dat) <- c("date_time","temp_C")
temp_dat %<>%
  transform(date_time = mdy_hms(date_time))

# plot
temp_dat %>%
  ggplot(aes(date_time,temp_C)) +
  geom_point()

```


From the above plot, we can see that the logger is exposed to air rathwr than water; we would like to flag the data between approximately 7/4/2022 12:00:00 to 7/6/2022 12:00:00.
