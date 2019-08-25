rm(list=ls())
# +84 922824955
library(rvest)
library(stringr)
library(RSelenium)
library(rJava)
library(XML)

# cd c:\selenium
# java -Dwebdriver.gecko.driver="geckodriver.exe" -jar selenium-server-standalone-3.9.0.jar -port 4449


ch=wdman::chrome(port=4449L) #크롬드라이버를 포트 4449번에 배정
remDr=remoteDriver(remoteServerAddr = "localhost", port=4449L, browserName='chrome') #remort설정
remDr$open() #크롬 Open
remDr$navigate("https://www.amway.co.kr/") # 홈페이지 이동

btn = remDr$findElement(using = "xpath" , value = '//*[@id="header"]/header/div[1]/nav/div/div[2]/div/div[2]/ul/li[1]/a/img')
btn$clickElement() # 검색


#btn = remDr$findElement(using = "xpath" , value = '/html/body/div[2]/div[3]/div/form/div/img')
#btn$clickElement() # 검색

btn2 = remDr$findElement(using = "xpath" , value = '//*[@id="header"]/header/div[2]/nav/div/div[2]/div[1]/div/ul/li[2]')
btn2$clickElement() #


frontPage = remDr$getPageSource()
frontPage[[1]]
total_contents = read_html(frontPage[[1]]) %>% html_nodes('.tblListLos')%>% html_text()
total_contents = gsub("\n","",total_contents)
total_contents = gsub("\t","",total_contents)
total_contents = gsub("뉴스 \\(총","",total_contents)
total_contents = trimws(gsub("건 검색\\)","",total_contents))
total_contents = as.integer(total_contents)


last_page = read_html(frontPage[[1]]) %>% html_nodes('.PageNav') %>%html_text()
last_page = gsub("\t" , "" ,last_page)
last_page = gsub("\n" , "" ,last_page)
last_page
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
last_page = as.integer(substrRight(last_page,1))


df = data.frame(title = rep(NA,total_page) , main = rep(NA,total_page))
for(i in 0:last_page-1) {
  for(j in 1:10) {
    
    btn4 = remDr$findElement(using = "xpath" , value = paste0('/html/body/div[3]/div/div[2]/div[3]/ul/li[',j,']/a'))
    btn4$clickElement() # 페이지 내부 접속
    frontPage = remDr$getPageSource()
    df$main[(i*10 + j)] = read_html(frontPage[[1]]) %>% html_nodes('.newsContents.font1')%>% html_text()
    df$main[(i*10 + j)] = gsub("\n","",df$main[(i*10 + j)])
    df$main[(i*10 + j)] = gsub("\t","",df$main[(i*10 + j)])
    df$main[(i*10 + j)] = trimws(gsub("<U+.*>", "", df$main[(i*10 + j)])) # <U~~> 제거
    df$main[(i*10 + j)] = trimws(gsub("//슬라이드.*리스트보기카드보기","",df$main[(i*10 + j)]))
    
    df$title[(i*10 + j)] = read_html(frontPage[[1]]) %>%  html_nodes('.newsTitle') %>% html_text()
    df$title[(i*10 + j)] = gsub("\t","",df$title[(i*10 + j)])
    df$title[(i*10 + j)] = gsub("\n","",df$title[(i*10 + j)])
    df$title[(i*10 + j)] = trimws(gsub("<U+.*>", "", df$title[(i*10 + j)]))
    
    Sys.sleep(3)
    remDr$goBack() # 뒤로가기
    
  }
  btn5 = remDr$findElement(using = "xpath" , value = paste0('/html/body/div[3]/div/div[2]/div[3]/div[2]/a[',(i+2),']')) # 페이지 이동
  btn5$clickElement()
  Sys.sleep(3)
}

remDr$close() #크롬 Close
df

setwd("C:/Users/guswh/Desktop/잡동")
write.csv(df,"dailypharm.csv")




## 연습
df[1]
kkk = df[1,2]
gsub("//슬라이드.*리스트보기카드보기      ","",kkk)
trimws(gsub(".*.리스트보기카드보기","",kkk))

trimws(gsub("^\\s*<U\\+\\w+>|-", "", df$title[(i*10 + j)]))

abc = "abcd<U+00A0>asdasdasd"
gsub("<U+.*>", "",abc)
trimws(gsub("^\\s*<U\\+\\w+>|-", " ", abc))

read_html(frontPage[[1]]) %>%  html_nodes('.newsTitle') %>% html_text()

btn4 = remDr$findElement(using = "xpath" , value = '/html/body/div[3]/div/div[2]/div[3]/ul/li[1]/a')
btn4$clickElement()

frontPage = remDr$getPageSource() #페이지 전체 소스 가져오기

abc = read_html(frontPage[[1]]) %>% html_nodes('.newsContents.font1')%>% html_text()
gsub("\\<-\\>","", abc)


btn5 = remDr$findElement(using = "xpath" , value = paste0('/html/body/div[3]/div/div[2]/div[3]/div[2]/a[',(2),']'))
btn5$clickElement()

remDr$close() #크롬 Close

###