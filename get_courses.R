library(tidyverse)


args <- commandArgs(trailingOnly = TRUE)
url <- args[1]

course_col <- read_delim(url, delim = '|', skip = 2) %>%
    rename(course = " Course                                                                                                ") %>%
    select(course) %>%
    slice(2:n()) %>%
    filter(course != "                                                                                                       ")

course_df <- course_col %>%
    separate(course, into = c('course_code', 'course_link'), sep = '\\]\\(', fill = 'right') %>%
    filter(!is.na(course_link)) %>%
    mutate(course_code = str_remove(course_code, '\\['),
           course_code = str_trim(course_code)) %>%
    mutate(course_link = str_remove(course_link, '\\)'),
           course_link = str_trim(course_link)) %>%
    mutate(course_link = str_replace(course_link, 'https://github.ubc.ca/', 'git@github.ubc.ca:'),
           course_link = paste0(course_link,'.git'))

course_list <- pmap(course_df, list)

get_repos <- function(.course){
    .code = .course$course_code
    .link = .course$course_link
    
    .cmd_1 = paste('git', 'clone', .link, .code, sep = ' ')
    .cmd_2 = paste('cd', .code, '&&', 'rm', '-rf', '.git', sep = ' ')
    system(.cmd_1)
    system(.cmd_2)
}

system('rm -rf courses/')
system('mkdir courses && cd courses/')
map(course_list, get_repos)
system('mv DSCI_5* courses/')
