# 
# 输入单个省份的索引url
# 分析页面，找出所有地级市的名称，年份，网页链接，
# 整理成一个data.frame
# 另外再写入txt文件，以备校对
# 建立以省份命名的文件夹，例如“江苏省”，里面存储“江苏省_index.txt“文件


require(rvest)
require(stringr)


# 单个省份索引url
# 例如：安徽省统计公报索引
# pvc_url <- "http://www.tjcn.org/help/3551.html"


SetPvc <- function(name, pvc_url) {
  message("开始请求网站。。。可能要等好久呢(╯‵□′)╯︵┻━┻")
  html_code <- read_html(pvc_url, encoding = "GB18030") 
  message("响应成功啦啦啦~~~")
  
  # 提取标题信息，用于校对。
  title <- html_code %>% 
    html_node("h2") %>%
    html_text()
  message("开始爬取：", title)
  
  pvc <- str_replace(title, pattern = "^(.+)统计公报索引$", replacement = "\\1")
  # check
  if (str_sub(name, 1, 2) == str_sub(pvc, 1, 2)) {
    message("校对省份名称成功")
  } else {
    message("校对省份名称出现问题：", name, " != ", pvc, "!!!!!!!!!!!!!!!")
  }
  
  # 生成“地级市和available年份”列表
  cy_list <- html_code %>%
    html_nodes(".sy+ .sy .tt td") %>%
    html_text() %>%
    str_replace_all(pattern = "\\s+\r\n\\s+", replacement = "　")
  
  cy_list
  #  可以把这个城市年份列表写成一个文件，供校对用。
  
  # 找出每个城市、年份的连接地址
  cy_link <- html_code %>%
    html_nodes(".sy+ .sy .tt a") %>%
    html_attr("href")
  cy_link
  
  # 检查一下1
  check1 <- sum(str_count(cy_list, pattern = "\\d{4}")) == length(cy_link)
  if (!check1) {
    warning("城市列表里的年份总数 != link 数目", name)
  }
  
  # 整理成表格
  df <- data.frame()
  for (i in seq(1, length(cy_list), by = 2)) {
    # i 是 “石家庄市”
    # i + 1 是 "2015　2014　... 2001　2000　" 
    
    c_name <- cy_list[i]
    c_years <- cy_list[i+1] %>%
      str_extract_all(pattern = "\\d{4}") %>%
      unlist() %>%
      str_trim()
    c_df <- data.frame(city = c_name, years = c_years)
    df <- rbind(df, c_df)
  }
  
  # 检查一下2
  check2 <- nrow(df) == length(cy_link)
  if (!check2) {
    warning("nrow(df) != link 数目", name)
  }
  
  df$link <- cy_link
  df
  
  # 建立省份文件夹，写文件
  dir.create(pvc)
  index_file_name <- paste0(pvc, "_index", ".txt")
  write.table(df, row.names = F, file = file.path(pvc, index_file_name))
  
  return(0)
}

# SetPvc(name = "西藏", pvc_url = "http://www.tjcn.org/help/3571.html")
# 
# # 
