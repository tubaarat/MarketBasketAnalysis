#Tum kullanicilarin bir sonraki alisverisinin gununun hesaplandigi kod
#Gunler kumulatif

#Klasik import k?sm?
trdata=read.csv("train.csv")
tsdata=read.csv("test.csv")

#Iki dosya icin de kullanici id leri unique olarak depolanir.
truserlist=unique(trdata$user_id)
tsuserlist=unique(tsdata$user_id)

#Son tahminlerin tutulacagi vektor bos olarak olusturulur
predicted_day_vector=vector()
predmin<-vector()
predmax<-vector()


#Her bir kullanici icin onun tum alisverin gun araligi try vekt?r?ne eklenir
#Trx de 0 dan onun uzunluguna kadar sayilar olur
for (i in (1:length(truserlist))){ 
try<-c(unique(trdata$days_since_first_order[which(trdata$user_id==i)]))
trx<-seq(0,length(try)-1)

#Iki vektor bir dataframe e aktarilip regresyon modeli cikartilir.
trregress_data<-data.frame(try, trx)
a <- trregress_data$try
x <- trregress_data$trx
trlinearMod <- lm(a ~ x) 
 
#N+1 inci deger anlamina gelen (length try) sayisina karsilik gelen eleman tahmin ettirilir 
y_pred = predict(trlinearMod, data.frame(x = length(try)),interval="confidence") 

if(i==1){
png(file = "user_regression.png")
par(mfrow = c(2, 2))
plot(trx,try,xlim=c(0, (length(try)+1)),ylim=c(0, (y_pred[[1]]+10)),col = "blue",main = "Regression For User:1",
abline(trlinearMod),cex = 1.3,pch = 16,xlab = "Orders",ylab = "Days after first order")
points(length(try), y_pred[[1]], pch=8, col="red")
}
if(i==2){
plot(trx,try,xlim=c(0, (length(try)+1)),ylim=c(0, (y_pred[[1]]+10)),col = "blue",main = "Regression For User:2",
abline(trlinearMod),cex = 1.3,pch = 16,xlab = "Orders",ylab = "Days after first order")
points(length(try), y_pred[[1]], pch=8, col="red")
} 
if(i==3){
plot(trx,try,xlim=c(0, (length(try)+1)),ylim=c(0, (y_pred[[1]]+10)),col = "blue",main = "Regression For User:4",
abline(trlinearMod),cex = 1.3,pch = 16,xlab = "Orders",ylab = "Days after first order")
points(length(try), y_pred[[1]], pch=8, col="red")
} 
if(i==4){
plot(trx,try,xlim=c(0, (length(try)+1)),ylim=c(0, (y_pred[[1]]+10)),col = "blue",main = "Regression For User:3",
abline(trlinearMod),cex = 1.3,pch = 16,xlab = "Orders",ylab = "Days after first order")
points(length(try), y_pred[[1]], pch=8, col="red")
dev.off()
} 


#tahminler bir vektorun sonuna eklenir
predicted_day_vector<-append(predicted_day_vector,y_pred[[1]] )
if(!is.na(y_pred[[2]]) )
{
predmin<-append(predmin,y_pred[[2]] )
predmax<-append(predmax,y_pred[[3]] )
}
else{
predmin<-append(predmin,y_pred[[1]] )
predmax<-append(predmax,y_pred[[1]] )
}

}

#Gorsellestirme islemi icin kullanilacak bos vektorler olusturulur.
actuals<-vector()
predicteds<-vector()
lastuserlist<-vector()
lastmin<-vector()
lastmax<-vector()

#Her train kullanicisi testte de aranir varsa
for (i in (1:length(truserlist))){ 
if(i %in% tsuserlist){

#Tahmin edilen deger, gercek deger ve tahmin yapilan kullanici sirasiyla ilgili vektorlere atilir.
actuals<-append(actuals,unique(tsdata$days_since_first_order[which(tsdata$user_id==i)]))
predicteds<-append(predicteds,predicted_day_vector[i])
lastuserlist<-append(lastuserlist,i)
lastmin<-append(lastmin,predmin[i])
lastmax<-append(lastmax,predmax[i])
}
}

#Min_max basari sonucu ve son hal data frame olarak ekrana bast?r?l?r
actuals_preds <- data.frame(cbind(actuals, predicteds))
min_max_accuracy <- mean (apply(actuals_preds, 1, min) / apply(actuals_preds, 1, max))  
son_hal_gunler<-data.frame(lastuserlist, actuals,predicteds,lastmin,lastmax)
print("Son Hal-Gunlere Gore")
print(head(son_hal_gunler))
print("Basari orani min-max:)")
print(min_max_accuracy )








#Her bir kullanici icin almis oldugu her urunun bir sonraki al?nabilecegi gunu hesaplayan kod
#Gunler kumulatif

#Kodun calismasi uzun suruyor (1.5-2 dk performansa bagli), eger ciktilari alip kullanilmak
#istenirse son_hal isimli dataframe de duzgun sekilde mevcut

#Klasik import
trdata=read.csv("train.csv")
tsdata=read.csv("test.csv")
names=read.csv("products.csv")

#Iki dosya icin de kullanici id leri unique olarak depolanir.
truserlist=unique(trdata$user_id)
tsuserlist=unique(tsdata$user_id)

#train icin kullan?lacak olan unique urun listesi
trproductlist=unique(trdata$product_id)

#Her bir kisi icin kullanilacak mini urun vektoru
productlistforperson=vector()

#Programda kullan?lan her satiri bir user ve her sutunu bir urunu temsil eden
#Kocaman matris ici 0
mymatrix=matrix(0,length(truserlist)  , length(trproductlist)  ) 
minmatrix=matrix(0,length(truserlist)  , length(trproductlist)  ) 
maxmatrix=matrix(0,length(truserlist)  , length(trproductlist)  ) 

for (i in (1:length(truserlist))){ 

#Her bit train kullanicisiicin once alinan tum urunler vektorde tutulur
productlistforperson<-c(unique(trdata$product_id[which(trdata$user_id==i)]))

for (j in productlistforperson){ 
#Listediki her bir urun icin alinan gunler vektore aktarilarak regresyon yapilir
try<-c(trdata$days_since_first_order[intersect(which(trdata$user_id==i),which(trdata$product_id==j)    )])
trx<-seq(0,length(try)-1)
trregress_data<-data.frame(try, trx)
a <- trregress_data$try
x <- trregress_data$trx
trlinearMod <- lm(a ~ x)

#Tahmin ancak uzunluk 2 den b?y?kse yani NULL ya da 0 bos degilse yapilir (Zaten degerler 
# 3 basamakli min)
if(length(try)>=2){
y_pred = predict(trlinearMod, data.frame(x = length(try)),interval="confidence") 

#Ornek 4 tane grafik bastirilir
if((i==1)&&(j==196)){
png(file = "product_regression.png")
par(mfrow = c(2, 2))
plot(trx,try,xlim=c(0, (length(try)+1)),ylim=c(0, (y_pred[[1]]+10)),col = "blue",main = "Regression For User:1 Product:196",
abline(trlinearMod),cex = 1.3,pch = 16,xlab = "Orders",ylab = "Days after first order")
points(length(try), y_pred[[1]], pch=8, col="red")
}
if((i==2)&&(j==47766)){
plot(trx,try,xlim=c(0, (length(try)+1)),ylim=c(0, (y_pred[[1]]+10)),col = "blue",main = "Regression For User:2 Product:47766",
abline(trlinearMod),cex = 1.3,pch = 16,xlab = "Orders",ylab = "Days after first order")
points(length(try), y_pred[[1]], pch=8, col="red")
dev.off()
} 
if((i==2)&&(j==32792)){
plot(trx,try,xlim=c(0, (length(try)+1)),ylim=c(0, (y_pred[[1]]+10)),col = "blue",main = "Regression For User:2 Product:32792",
abline(trlinearMod),cex = 1.3,pch = 16,xlab = "Orders",ylab = "Days after first order")
points(length(try), y_pred[[1]], pch=8, col="red")
} 
if((i==1)&&(j==10258)){
plot(trx,try,xlim=c(0, (length(try)+1)),ylim=c(0, (y_pred[[1]]+10)),col = "blue",main = "Regression For User:1 Product:10258",
abline(trlinearMod),cex = 1.3,pch = 16,xlab = "Orders",ylab = "Days after first order")
points(length(try), y_pred[[1]], pch=8, col="red")
} 
 

#Tahmin matrisin ilgili yerine yazilir
mymatrix[i,which(j == trproductlist)  ]<-y_pred[[1]]
if(!is.na(y_pred[[2]]) )
{
minmatrix[i,which(j == trproductlist)  ]<-y_pred[[2]]
maxmatrix[i,which(j == trproductlist)  ]<-y_pred[[3]]
}
else{
minmatrix[i,which(j == trproductlist)  ]<-y_pred[[1]]
maxmatrix[i,which(j == trproductlist)  ]<-y_pred[[1]]
}


}
}
}

#Gorsellestirme islemi icin kullanilacak bos vektorler olusturulur.
actuals<-vector()
predicteds<-vector()
lastuserlist<-vector()
pnames<-vector()
availableproductids<-vector()
lastmin<-vector()
lastmax<-vector()


#Tum train kullanicilari icin once testte karsiligi var mi diye bakilir
for (i in (1:length(truserlist))){ 
if(i %in% tsuserlist){

#Testte karsiligi varsa iki dosya icin de aldigi urunlere bakilir
productlistforperson<-c(unique(trdata$product_id[which(trdata$user_id==i)]))
tsproductlistforperson<-c(unique(tsdata$product_id[which(tsdata$user_id==i)]))
for (j in productlistforperson){ 

#aldigi urunlerde eslesme varsa
if(j %in% tsproductlistforperson){

#Matrisin o kisi ve o urun degeri bos degilse kontrolu
if(      mymatrix[i,which(j == trproductlist) ]!=0        ){

#Testteki gercek deger okunur
actuals<-append(actuals,tsdata$days_since_first_order[intersect(which(tsdata$user_id==i),which(tsdata$product_id==j)    )])

#Tahmin edilen deger, ilgili kullanici ve urun idleri vektorlere aktarilir.
predicteds<-append(predicteds,mymatrix[i,which(j == trproductlist) ])
lastuserlist<-append(lastuserlist,i)
availableproductids<-append(availableproductids,j)
lastmin<-append(lastmin,minmatrix[i,which(j == trproductlist) ])

lastmax<-append(lastmax,maxmatrix[i,which(j == trproductlist) ])


}
}
}
}
}

#Min_max_basari sonucu bulunur 
actuals_preds <- data.frame(cbind(actuals, predicteds))
min_max_accuracy <- mean (apply(actuals_preds, 1, min) / apply(actuals_preds, 1, max))  

#Urun idlerine karsilik gelen isimler dosyadan okunur ve vektore eklenir.
for (i in availableproductids){
pnames<-append(pnames,as.character(names$product_name[which(i == names$product_id)]))
}

#Min_max basari sonucu ve son hal data frame olarak ekrana bast?r?l?r
son_hal_urun<-data.frame(lastuserlist, availableproductids,pnames,actuals,predicteds,lastmin,lastmax)
print("Son Hal Urun")
print(head(son_hal_urun))
print(min_max_accuracy )


list_user<-vector()
list_urunid<-vector()
list_urunad<-vector()



for (i in (1:length(son_hal_urun$availableproductids))){

if(son_hal_urun$predicteds[i]<=son_hal_gunler$lastmax[which(son_hal_gunler$lastuserlist==son_hal_urun$lastuserlist[i])]){

list_user<-append( list_user  ,son_hal_urun$lastuserlist[i])
list_urunid<-append( list_urunid,son_hal_urun$availableproductids[i])
list_urunad<-append( list_urunad,as.character(son_hal_urun$pnames[i]))

}
}

son_liste<-data.frame(list_user,list_urunid,list_urunad)
print(son_liste)

toplam_tutarlilik=0
basari_orani_liste=0
kisisel_tutarlilik<-vector()

for (i in unique(son_hal_urun$lastuserlist)){

kisisel_tutarlilik<-append(kisisel_tutarlilik,length(intersect(son_hal_urun$availableproductids[which(son_hal_urun$lastuserlist==i)],son_liste$list_urunid[which(son_liste$list_user==i)]))    / length(union(son_hal_urun$availableproductids[which(son_hal_urun$lastuserlist==i)],son_liste$list_urunid[which(son_liste$list_user==i)]))                )
toplam_tutarlilik=toplam_tutarlilik+length(intersect(son_hal_urun$availableproductids[which(son_hal_urun$lastuserlist==i)],son_liste$list_urunid[which(son_liste$list_user==i)]))    /length(union(son_hal_urun$availableproductids[which(son_hal_urun$lastuserlist==i)],son_liste$list_urunid[which(son_liste$list_user==i)]))             
}

basari_orani_liste=toplam_tutarlilik/length(unique(son_hal_urun$lastuserlist))

print("Tum listenin son basari orani: A.O.(Eslesen Urun Kumesi/Gercek Urun Kumesi)")
print(basari_orani_liste)

ordernumber<-vector()
orderlength<-vector()

for (i in unique(son_hal_urun$lastuserlist)){
k=length(unique(trdata$order_number[which(trdata$user_id==i)]))
t=data.frame(table(trdata$order_number[which(trdata$user_id==i)]))
ordernumber<-append(ordernumber,k)
orderlength<-append(orderlength,sum(t$Freq)/length(t$Freq))
}

orders_basari<-data.frame(ordernumber,kisisel_tutarlilik)
BasariOrani<-vector()
SiparisSayisi<-sort(unique(orders_basari$ordernumber))
for (i in SiparisSayisi){
BasariOrani<-append(BasariOrani,sum(orders_basari$kisisel_tutarlilik[which(orders_basari$ordernumber==i)])/length(orders_basari$kisisel_tutarlilik[which(orders_basari$ordernumber==i)]))
}

orders_length_basari<-data.frame(orderlength,kisisel_tutarlilik)
BasariOrani_length<-vector()
SiparisSayisi_length<-sort(unique(orders_length_basari$orderlength))
for (i in SiparisSayisi_length){
BasariOrani_length<-append(BasariOrani_length,sum(orders_length_basari$kisisel_tutarlilik[which(orders_length_basari$orderlength==i)])/length(orders_length_basari$kisisel_tutarlilik[which(orders_length_basari$orderlength==i)]))
}


kisisel_basari<-data.frame(SiparisSayisi,BasariOrani)
kisisel_basari_length<-data.frame(SiparisSayisi_length,BasariOrani_length)

png(file = "Siparis Sayisina Gore Basari Orani.png")
barplot(kisisel_basari$BasariOrani,
main = "Siparis Sayisina Gore Basari Orani",
xlab = "Bilinen Siparis Sayisi",
ylab = "Liste Tahmininde Basari Orani",col = "darkred",
names.arg = kisisel_basari$SiparisSayisi
)
dev.off()

png(file = "Ortalama Siparis Buyuklugune Gore Basari Orani.png")
barplot(kisisel_basari_length$BasariOrani_length,
main = "Ortalama Siparis Buyuklugune Gore Basari Orani",
xlab = "Ortalama Siparis Buyuklugune ",
ylab = "Liste Tahmininde Basari Orani",col = "darkred",
names.arg = kisisel_basari_length$SiparisSayisi_length
)
dev.off()
print("AfterARM")


######
########
#####
armdata=read.csv("armdata.csv")

list_user<-vector()
list_urunid<-vector()
list_urunad<-vector()

for (i in (1:length(son_hal_urun$availableproductids))){

if(son_hal_urun$predicteds[i]<=son_hal_gunler$lastmax[which(son_hal_gunler$lastuserlist==son_hal_urun$lastuserlist[i])]){

list_user<-append( list_user  ,son_hal_urun$lastuserlist[i])
list_urunid<-append( list_urunid,son_hal_urun$availableproductids[i])
list_urunad<-append( list_urunad,as.character(son_hal_urun$pnames[i]))

}
}

added<-vector()
for (i in (1:length(armdata$user_id))){
z=son_liste$list_urunid[which(son_liste$list_user==armdata$user_id[i])]
if(length(z)>=1){
if((armdata$product1[i] %in% z)&& (!(armdata$product2[i] %in% z))){
if(!(armdata$product2[i] %in% added)){
list_user<-append( list_user  ,armdata$user_id[i])
list_urunid<-append( list_urunid,armdata$product2[i])
list_urunad<-append( list_urunad,as.character(names$product_name[which(names$product_id==armdata$product2[i] )]))
added<-append(added,armdata$product2[i])
}
}
}
}

son_liste<-data.frame(list_user,list_urunid,list_urunad)
print("ARM dahil son liste")
print(son_liste)

toplam_tutarlilik=0
basari_orani_liste=0
kisisel_tutarlilik<-vector()

for (i in unique(son_hal_urun$lastuserlist)){

kisisel_tutarlilik<-append(kisisel_tutarlilik,length(intersect(son_hal_urun$availableproductids[which(son_hal_urun$lastuserlist==i)],son_liste$list_urunid[which(son_liste$list_user==i)]))    / length(union(son_hal_urun$availableproductids[which(son_hal_urun$lastuserlist==i)],son_liste$list_urunid[which(son_liste$list_user==i)]))                )
toplam_tutarlilik=toplam_tutarlilik+length(intersect(son_hal_urun$availableproductids[which(son_hal_urun$lastuserlist==i)],son_liste$list_urunid[which(son_liste$list_user==i)]))    /length(union(son_hal_urun$availableproductids[which(son_hal_urun$lastuserlist==i)],son_liste$list_urunid[which(son_liste$list_user==i)]))             
}

basari_orani_liste=toplam_tutarlilik/length(unique(son_hal_urun$lastuserlist))

print("ARM dahil Tum listenin son basari orani: A.O.(Eslesen Urun Kumesi/Gercek Urun Kumesi)")
print(basari_orani_liste)

ordernumber<-vector()
orderlength<-vector()

for (i in unique(son_hal_urun$lastuserlist)){
k=length(unique(trdata$order_number[which(trdata$user_id==i)]))
t=data.frame(table(trdata$order_number[which(trdata$user_id==i)]))
ordernumber<-append(ordernumber,k)
orderlength<-append(orderlength,sum(t$Freq)/length(t$Freq))
}

orders_basari<-data.frame(ordernumber,kisisel_tutarlilik)
BasariOrani<-vector()
SiparisSayisi<-sort(unique(orders_basari$ordernumber))
for (i in SiparisSayisi){
BasariOrani<-append(BasariOrani,sum(orders_basari$kisisel_tutarlilik[which(orders_basari$ordernumber==i)])/length(orders_basari$kisisel_tutarlilik[which(orders_basari$ordernumber==i)]))
}

orders_length_basari<-data.frame(orderlength,kisisel_tutarlilik)
BasariOrani_length<-vector()
SiparisSayisi_length<-sort(unique(orders_length_basari$orderlength))
for (i in SiparisSayisi_length){
BasariOrani_length<-append(BasariOrani_length,sum(orders_length_basari$kisisel_tutarlilik[which(orders_length_basari$orderlength==i)])/length(orders_length_basari$kisisel_tutarlilik[which(orders_length_basari$orderlength==i)]))
}


kisisel_basari<-data.frame(SiparisSayisi,BasariOrani)
kisisel_basari_length<-data.frame(SiparisSayisi_length,BasariOrani_length)

png(file = "ARM dahil Siparis Sayisina Gore Basari Orani.png")
barplot(kisisel_basari$BasariOrani,
main = "ARM dahil Siparis Sayisina Gore Basari Orani",
xlab = "Bilinen Siparis Sayisi",
ylab = "Liste Tahmininde Basari Orani",col = "darkred",
names.arg = kisisel_basari$SiparisSayisi
)
dev.off()

png(file = "ARM dahil Ortalama Siparis Buyuklugune Gore Basari Orani.png")
barplot(kisisel_basari_length$BasariOrani_length,
main = "ARM dahil Ortalama Siparis Buyuklugune Gore Basari Orani",
xlab = "Ortalama Siparis Buyuklugune ",
ylab = "Liste Tahmininde Basari Orani",col = "darkred",
names.arg = kisisel_basari_length$SiparisSayisi_length
)
dev.off()

