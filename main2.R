
rm(list = ls())

require(rvest)
require(data.table)

start_url <- "http://www.tjcn.org/tjgb/"

res <- read_html(start_url)

pvc_list_text <- 
  html_nodes(res, "p+ p a") %>%
  html_text()
pvc_list_link <- 
  html_nodes(res, "p+ p a") %>%
  html_attr("href")

df <- data.frame(
  name = pvc_list_text, 
  link = pvc_list_link, 
  stringsAsFactors = FALSE
)

df2 <- data.frame()
for (i in 1:nrow(df)){
  pvc_name <- df[i, "name"]
  pvc_url <- paste0("http://www.tjcn.org/", df[i, "link"])
  # visit this url, get the year link: Beijing 2015
  
  pvc_page <- 
    read_html(pvc_url, encoding = "GB18030") %>% 
    html_nodes(".sy:nth-child(1) a")
  year_list_text <- html_text(pvc_page)
  year_list_link <- html_attr(pvc_page, "href")
  
  df2_loop <- data.frame(
    name = pvc_name,
    year = year_list_text,
    link = year_list_link
  )
  
  message(i)
  df2 <- rbind(df2, df2_loop)
}

dt <- data.table(df2)
dt[, name := as.character(name)]
dt[, year := as.integer(as.character(year))]
dt[, link := as.character(link)]
dt <- dt[year >= 2000]
dt <- dt[368:nrow(dt)] #去掉全国、北京、天津
dt <- dt[!(110:317)]  # 去掉上海
dt <- dt[!(351:724)]  # 去掉重庆&海南多余的部分
dt <- dt[!(c(96:109, 222:234, 251:286))]



# =====================================================
source("one_city_year.R")

# 建一个文件夹，设路径
setwd("/Users/jiaru2014/Desktop/kalel/pvc")

# 循环
for (i in 1:nrow(dt)){
  
  name <- dt[i, name]
  year <- dt[i, year]
  file_name <- paste0(name, "_", year, ".txt")
  link <- paste0("http://www.tjcn.org", dt[i, link])
  
  tryCatch(
    {
      ScpCY(link)
      message(name, year, "成功~~")
    },
    error = function(e) {
      cat(name, year, "爬取失败。。。", "\n", file = "log.txt", append = T)
    }
  )
  
}

system("textutil -convert doc *.txt")
system("mkdir txtfiles")  # terminal command 新建文件夹
system("mv *.txt txtfiles")  # terminal command move files


setwd("/Users/jiaru2014/Desktop/kalel")




