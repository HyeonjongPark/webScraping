
## 암웨이 제품 크롤링.


# cd c:\selenium
# java -Dwebdriver.gecko.driver="geckodriver.exe" -jar selenium-server-standalone-3.9.0.jar -port 4446


library(rvest)
library(stringr)
library(RSelenium)
library(rJava)
library(XML)

ch=wdman::chrome(port=4446L) #크롬드라이버를 포트 4567번에 배정
remDr=remoteDriver(remoteServerAddr = "localhost", port=4446L, browserName='chrome') #remort설정
remDr$open() #크롬 Open
remDr$navigate("https://mybiz.amwayglobal.com/mybiz/los.html")
#remDr$navigate("https://www.amway.co.kr/business/record/report/business-achieve/reportPopup") #설정 URL로 이동 쇼핑몰리스트

id = remDr$findElement(using = "xpath" , value = '//*[@id="id"]')
pw = remDr$findElement(using = "xpath" , value = '//*[@id="pw"]')

#id$sendKeysToElement(list("")) # 아이디 입력
#pw$sendKeysToElement(list("")) # 비밀번호 입력

btn = remDr$findElement(using = "xpath" , value = '//*[@id="frmNIDLogin"]/fieldset/input')
btn$clickElement()


frontPage = remDr$getPageSource() #페이지 전체 소스 가져오기
frontPage

read_html(frontPage[[1]]) %>% html_nodes('.dashboard-group-performance.mod')

remDr$close() #크롬 Close

productNames = read_html(frontPage[[1]]) %>% html_nodes('.product__list--wrapper.search-list-page-right-result-list-component') %>% 
  html_nodes(".product-list__item-detail") %>% 
  html_nodes(".product-list__item-title") %>% html_text() #제품 이름 부분 추출하기 


number_list = read_html(frontPage[[1]]) %>%  html_nodes('.product__list--wrapper.search-list-page-right-result-list-component') %>% 
  html_nodes(".product-list__item-detail") %>%
  html_nodes(".product-list__item-abovalue") %>% html_text()

productNames
rowSelectNames = seq(1,length(productNames),4)
productNames = productNames[rowSelectNames]

rowSelectPV_BV = seq(2,length(number_list) , 3)
productPV_BV = number_list[rowSelectPV_BV]


rowSelectPrice = seq(3 , length(number_list),3)
productPrice = number_list[rowSelectPrice]
productPrice


df = data.frame(name = productNames , PV_BV = productPV_BV , price = productPrice)

for(i in 1:length(productPV_BV)){
  df$pv[i] = strsplit(productPV_BV , " / ")[[i]][1]
  df$bv[i] = strsplit(productPV_BV , " / ")[[i]][2]
}

df = df[,-2]
head(df)
str(df)

df$price = gsub("원","",df$price)
df$price = gsub(",","",df$price)

df$pv = gsub(",","",df$pv)
df$bv = gsub(",","",df$bv)
df$name = gsub("<U+2013>","-",df$name)
head(df)
tail(df)

df$price = as.numeric(df$price)
df$pv = as.numeric(df$pv)
df$bv = as.numeric(df$bv)
library(dplyr)

df %>% arrange

attach(df)
lm(price ~ pv+bv)
m1 = lm(price ~ pv)
m2 = lm(price ~ bv)
m3 = lm(price ~ pv+bv)
plot(price ~ pv , xlab = "pv" , ylab ="price" )
abline(m1 , col ="blue")

plot(price ~ bv , xlab = "bv" , ylab = "price")
abline(m2 , col = "red")

summary(m1)
summary(m2)
summary(m3)

