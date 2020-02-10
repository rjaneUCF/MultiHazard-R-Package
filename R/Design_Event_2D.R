#' Derives a single or ensemble of bivariate design events
#'
#' Calculates the single design event under the assumption of full dependence, or once accounting for dependence between variables the single "most-likely" or an ensemble of possible design events.
#'
#' @param Data Dataframe of dimension \code{nx2} containing two co-occurring time series of length \code{n}.
#' @param Data_Con1 Dataframe containing the conditional sample (declustered excesses paired with concurrent values of other variable), conditioned on the variable in the first column.
#' @param Data_Con2 Dataframe containing the conditional sample (declustered excesses paired with concurrent values of other variable), conditioned on the variable in the second column. Can be obtained using the \code{Con_Sampling_2D} function.
#' @param Thres1 Numeric vector of length one specifying the threshold above which the variable in the first column was sampled in Data_Con1.
#' @param Thres2 Numeric vector of length one specifying the threshold above which the variable in the second column was sampled in Data_Con2.
#' @param Copula_Family1 Numeric vector of length one specifying the copula family used to model the \code{Data_Con1} dataset.
#' @param Copula_Family2 Numeric vector of length one specifying the copula family used to model the \code{Data_Con2} dataset. Best fitting of 40 copulas can be found using the \code{Copula_Threshold_2D} function.
#' @param Marginal_Dist1 Character vector of length one specifying (non-extreme) distribution used to model the marginal distribution of the non-conditioned variable.
#' @param Marginal_Dist2 Character vector of length one specifying (non-extreme) distribution used to model the marginal distribution of the non-conditioned variable. Best fitting among two truncted distributions or eight truncated distributions can be found using the functions.
#' @param Con2 Character vector of length one specifying the name of variable in the first column of \code{Data}.
#' @param Con2 Character vector of length one specifying the name of variable in the second column of \code{Data}.
#' @param mu Numeric vector of length one specifying the (average) number of events per year. Default is \code{365.25}, daily data.
#' @param RP Numeric vector of length one specifying the return period of interest.
#' @param x_lab Charactor vector specifying the x-axis label.
#' @param y_lab Charactor vector specifying the y-axis label.
#' @param N Numeric vector of length one specifying the size of the sample from the fitted joint distributions used to estimate the density along an isoline. Samples are collected from the two joint distribution with proportions consistent with the total number of exteme events conditioned on each variable.
#' @param N_Ensemble Numeric vector of length one specifying the number of possible design events sampled along the isoline of interest.
#' @return Plot of all the observations (grey circles) as well as the declustered excesses above Thres1 (blue circles) or Thres2 (blue circles), observations may belong to both conditional samples. Also shown is the isoline associated with \code{RP} contoured according to their relative probability of occurrence on the basis of the sample from the two joint distributions, the "most likely" design event (black diamond), and design event under the assumption of full dependence (black triangle) are also shown in the plot. The function also returns a list comprising the design events assuming full dependence \code{"FullDependence"}, as well as once the dependence between the variables is accounted for the "Most likley" {"MostLikelyEvent"} as well as an {"Ensemble"} of possible design events.
#' @export
#' @examples
#'S22.Rainfall<-Con_Sampling_2D(Data_Detrend=S22.Detrend.df[,-c(1,4)],Data_Declust=S22.Detrend.Declustered.df[,-c(1,4)],Con_Variable="Rainfall",Thres=0.97)
#'S22.OsWL<-Con_Sampling_2D(Data_Detrend=S22.Detrend.df[,-c(1,4)],Data_Declust=S22.Detrend.Declustered.df[,-c(1,4)],Con_Variable="OsWL",Thres=0.97)
#'S22.Copula.Rainfall<-Copula_Threshold_2D(Data_Detrend=S22.Detrend.df[,-c(1,4)],
#'                                         Data_Declust=S22.Detrend.Declustered.df[,-c(1,4)],Thres =0.97,
#'                                         y_lim_min=-0.075,y_lim_max=0.25,
#'                                         Upper=c(2,9),Lower=c(2,10),GAP=0.15)$Copula_Family_Var1
#'S22.Copula.OsWL<-Copula_Threshold_2D(Data_Detrend=S22.Detrend.df[,-c(1,4)],
#'                                     Data_Declust=S22.Detrend.Declustered.df[,-c(1,4)],Thres =0.97,
#'                                     y_lim_min=-0.075, y_lim_max =0.25,
#'                                    Upper=c(2,9),Lower=c(2,10),GAP=0.15)$Copula_Family_Var2
#'Design_Event_2D(Data=S22.Detrend.df[,-c(1,4)], Data_Con1=S22.Rainfall$Data,
#'                Data_Con2=S22.OsWL$Data, Thres1=0.97, Thres2=0.97,
#'                Copula_Family1=S22.Copula.Rainfall, Copula_Family2=S22.Copula.OsWL,
#'                Marginal_Dist1="Logis", Marginal_Dist2="Twe",RP=100,N=10,N_Ensemble=10)
Design_Event_2D<-function(Data, Data_Con1, Data_Con2, Thres1, Thres2, Copula_Family1, Copula_Family2, Marginal_Dist1, Marginal_Dist2, Con1="Rainfall",Con2="OsWL",mu=365.25, RP,x_lab="Rainfall (mm)",y_lab="O-sWL (mNGVD 29)",N,N_Ensemble){

con1<-which(names(Data)==Con1)
con2<-which(names(Data)==Con2)

##Fitting marginal distributions

  if(Marginal_Dist1 == "BS"){
   bdata2 <- data.frame(shape = exp(-0.5), scale = exp(0.5))
   bdata2 <- transform(bdata2, y = Data_Con1[,con2])
   marginal_non_con1<-vglm(y ~ 1, bisa, data = bdata2, trace = FALSE)
  }

  if(Marginal_Dist1 == "Exp"){
   marginal_non_con1<-fitdistr(Data_Con1[,con2],"exponential")
  }

 if(Marginal_Dist1 == "Gam"){
   marginal_non_con1<-fitdistr(Data_Con1[,con2], "gamma")
 }

 if(Marginal_Dist1 == "Gaus"){
  marginal_non_con1<-fitdistr(Data_Con1[,con2],"normal")
 }

 if(Marginal_Dist1 == "InvG"){
   marginal_non_con1<-fitdist(Data_Con1[,con2], "invgauss", start = list(mean = 5, shape = 1))
 }

 if(Marginal_Dist1 == "Logis"){
   marginal_non_con1<-fitdistr(Data_Con1[,con2], "logistic")
 }

 if(Marginal_Dist1 == "LogN"){
   marginal_non_con1<-fitdistr(Data_Con1[,con2],"lognormal")
 }

 if(Marginal_Dist1 == "Twe"){
   marginal_non_con1<-tweedie.profile(Data_Con1[,con2] ~ 1,p.vec=seq(1.5, 2.5, by=0.2), do.plot=FALSE)
 }

 if(Marginal_Dist1 == "Weib"){
  marginal_non_con1<-fitdistr(Data_Con1[,con2], "weibull")
 }

GPD_con1<-evm(Data_Con1[,con1], th=quantile(na.omit(Data[,con1]),Thres1) ,penalty = "gaussian",priorParameters = list(c(0, 0), matrix(c(100^2, 0, 0, 0.25), nrow = 2)))

if(Marginal_Dist2 == "BS"){
  bdata2 <- data.frame(shape = exp(-0.5), scale = exp(0.5))
  bdata2 <- transform(bdata2, y = Data_Con2[,con1])
  marginal_non_con2<-fit <- vglm(y ~ 1, bisa, data = bdata2, trace = FALSE)
}

if(Marginal_Dist2 == "Exp"){
  marginal_non_con2<-fitdistr(Data_Con2[,con1],"exponential")
}

if(Marginal_Dist2 == "Gam"){
  marginal_non_con2<-fitdistr(Data_Con2[,con1], "gamma")
}

if(Marginal_Dist2 == "Gaus"){
  marginal_non_con2<-fitdistr(Data_Con2[,con1],"normal")
}

if(Marginal_Dist2 == "InvG"){
  marginal_non_con2<-fitdist(Data_Con2[,con1], "invgauss", start = list(mean = 5, shape = 1))
}

if(Marginal_Dist2 == "Logis"){
  marginal_non_con2<-fitdistr(Data_Con2[,con1],"logistic")
}

if(Marginal_Dist2 == "LogN"){
  marginal_non_con2<-fitdistr(Data_Con2[,con1],"lognormal")
}

if(Marginal_Dist2 == "Twe"){
   marginal_non_con2<-tweedie.profile(Data_Con2[,con1] ~ 1,p.vec=seq(1.5, 2.5, by=0.2), do.plot=FALSE)
 }

if(Marginal_Dist2 == "Weib"){
  marginal_non_con2<-fitdistr(Data, "weibull")
}


GPD_con2<-evm(Data_Con2[,con2], th=quantile(na.omit(Data[,con2]),Thres2) ,penalty = "gaussian",priorParameters = list(c(0, 0), matrix(c(100^2, 0, 0, 0.25), nrow = 2)))

#Simulating from copulas
obj1<-BiCopSelect(pobs(Data_Con1[,1]), pobs(Data_Con1[,2]), familyset=Copula_Family1, selectioncrit = "AIC",
                  indeptest = FALSE, level = 0.05, weights = NA, rotations = TRUE,
                  se = FALSE, presel = TRUE, method = "mle")
sample<-BiCopSim(round(N*nrow(Data_Con1)/(nrow(Data_Con1)+nrow(Data_Con2)),0),obj1)
if(Marginal_Dist1=="BS"){
  cop.sample1.non.con<-qbisa(sample[,1], Coef(marginal_non_con2)[1], Coef(marginal_non_con2)[2])
}
if(Marginal_Dist1=="Exp"){
  cop.sample1.non.con<-qexp(sample[,1], rate = as.numeric(marginal_non_con1$estimate[1]))
}
if(Marginal_Dist1=="Gam"){
  cop.sample1.non.con<-qgamma(sample[,1], shape = as.numeric(marginal_non_con1$estimate[1]), rate = as.numeric(marginal_non_con1$estimate[2]))
}
if(Marginal_Dist1=="Gaus"){
  cop.sample1.non.con<-qnorm(sample[,1], mean = as.numeric(marginal_non_con1$estimate[1]), sd = as.numeric(marginal_non_con1$estimate[2]))
}
if(Marginal_Dist1=="InvG"){
  cop.sample1.non.con<-qinvgauss(sample[,1], mean = as.numeric(marginal_non_con1$estimate[1]), shape = as.numeric(marginal_non_con1$estimate[2]))
}
if(Marginal_Dist1=="Logis"){
  cop.sample1.non.con<-qlogis(sample[,1], location = as.numeric(marginal_non_con1$estimate[1]), scale = as.numeric(marginal_non_con1$estimate[2]))
}
if(Marginal_Dist1=="LogN"){
  cop.sample1.non.con<-qlnorm(sample[,1], meanlog = as.numeric(marginal_non_con1$estimate[1]), sdlog = as.numeric(marginal_non_con1$estimate[2]))
}
if(Marginal_Dist1=="Twe"){
  cop.sample1.non.con<-qtweedie(sample[,1], power=marginal_non_con1$p.max, mu=mean(Data_Con1[,con2]), phi=marginal_non_con1$phi.max)
}
if(Marginal_Dist1=="Weib"){
  cop.sample1.non.con<-qweibull(sample[,1], shape = as.numeric(marginal_non_con1$estimate[1]), scale=as.numeric(marginal_non_con1$estimate[2]))
}
cop.sample1.con<-u2gpd(sample[,2], p = 1, th=Thres1 , sigma=exp(GPD_con1$coefficients[1]),xi= GPD_con1$coefficients[2])
cop.sample1<-data.frame(cop.sample1.non.con,cop.sample1.con)
colnames(cop.sample1)<-c("Var1","Var2")

obj2<-BiCopSelect(pobs(Data_Con1[,1]), pobs(Data_Con1[,2]), familyset=Copula_Family1, selectioncrit = "AIC",
                  indeptest = FALSE, level = 0.05, weights = NA, rotations = TRUE,
                  se = FALSE, presel = TRUE, method = "mle")
sample<-BiCopSim(round(N*nrow(Data_Con2)/(nrow(Data_Con1)+nrow(Data_Con2)),0),obj2)

if(Marginal_Dist2=="BS"){
  cop.sample2.non.con<-qbisa(sample[,1], Coef(marginal_non_con2)[1], Coef(marginal_non_con2)[2])
}
if(Marginal_Dist2=="Exp"){
  cop.sample2.non.con<-qexp(sample[,1], rate = as.numeric(marginal_non_con2$estimate[1]))
}
if(Marginal_Dist2=="Gam"){
  cop.sample2.non.con<-qgamma(sample[,1], shape = as.numeric(marginal_non_con2$estimate[1]), rate=as.numeric(marginal_non_con2$estimate[2]))
}
if(Marginal_Dist2=="Gaus"){
  cop.sample2.non.con<-qnorm(sample[,1], mean = as.numeric(marginal_non_con2$estimate[1]), sd=as.numeric(marginal_non_con2$estimate[2]))
}
if(Marginal_Dist2=="InvG"){
  cop.sample2.non.con<-qinvgauss(sample[,1], mean = as.numeric(marginal_non_con2$estimate[1]), shape=as.numeric(marginal_non_con2$estimate[2]))
}
if(Marginal_Dist2=="LogN"){
  cop.sample2.non.con<-qlnorm(sample[,1], meanlog = as.numeric(marginal_non_con2$estimate[1]), sdlog = as.numeric(marginal_non_con2$estimate[2]))
}
if(Marginal_Dist1=="Logis"){
  cop.sample1.non.con<-qlogis(sample[,1], location = as.numeric(marginal_non_con1$estimate[1]), scale=as.numeric(marginal_non_con1$estimate[2]))
}
if(Marginal_Dist2=="Twe"){
  cop.sample2.non.con<-qtweedie(sample[,1], power=marginal_non_con2$p.max, mu=mean(Data_Con2[,con1]), phi=marginal_non_con2$phi.max)
}
if(Marginal_Dist2=="Weib"){
  cop.sample2.non.con<-qweibull(sample[,1], shape = as.numeric(marginal_non_con2$estimate[1]), scale=as.numeric(marginal_non_con2$estimate[2]))
}

cop.sample2.con<-u2gpd(sample[,2], p = 1, th=Thres2 , sigma=exp(GPD_con2$coefficients[1]),xi= GPD_con2$coefficients[2])
cop.sample2<-data.frame(cop.sample2.non.con,cop.sample2.con)
colnames(cop.sample2)<-c("Var1","Var2")
cop.sample<-rbind(cop.sample1,cop.sample2)

#Result vectors
x.MostLikelyEvent.AND<-numeric(1)
y.MostLikelyEvent.AND<-numeric(1)
x.full.dependence<-numeric(1)
y.full.dependence<-numeric(1)

#Copula object 1
u<-expand.grid(seq(0.0001,0.9999,0.0001),seq(0.0001,0.9999,0.0001))
u1<-BiCopCDF(u[,1], u[,2], obj1)

par(mar=c(4.5,4.2,0.5,0.5))
plot(Data[,con1],Data[,con2],xlim=c(min(na.omit(Data[,con1])),max(na.omit(Data[,con1]))),ylim=c(min(na.omit(Data[,con2])),max(na.omit(Data[,con2]))),col="Light Grey",xlab=x_lab,ylab=y_lab,cex.lab=1.5,cex.axis=1.5)
points(Data_Con1[,con1],Data_Con1[,con2],col=4,cex=1.5) #,xlab="Rainfall (mm)",ylab="OsWL (m NGVD)")
points(Data_Con2[,con1],Data_Con2[,con2],col=2,pch=4,cex=1.5)

x<- seq(0.0001,0.9999,0.0001)
y<- seq(0.0001,0.9999,0.0001)
years<-length(which(is.na(Data[,1])==FALSE & is.na(Data[,1])==FALSE))/mu
EL<-1/(nrow(Data_Con1)/years)

f<-function(x,y){EL/(1-x-y+u1[which(u[,1]==x & u[,2]==y)]) }
z<- outer(x,y,f)

#RP<-c(10,20,50,100)[k]
text(275,2.2,paste("RP:",RP,"years"),cex=1.5)

xy160<-contourLines(x,y,z,levels= RP)


con1.x<-u2gpd(as.numeric(unlist(xy160[[1]][2])), p = 1, th=quantile(na.omit(Data[,con1]),Thres1) , sigma=exp(GPD_con1$coefficients[1]),xi= GPD_con1$coefficients[2] )

if(Marginal_Dist1=="BS"){
  con1.y<-qbisa(as.numeric(unlist(xy160[[1]][3])),Coef(marginal_non_con1$estimate[1]),Coef(marginal_non_con1$estimate[2]))
}

if(Marginal_Dist1=="Exp"){
  con1.y<-qexp(as.numeric(unlist(xy160[[1]][3])),as.numeric(marginal_non_con1$estimate[1]))
}

if(Marginal_Dist1=="Gam"){
  con1.y<-qgamma(as.numeric(unlist(xy160[[1]][3])),as.numeric(marginal_non_con1$estimate[1]),as.numeric(marginal_non_con1$estimate[2]))
}

if(Marginal_Dist1=="Gaus"){
  con1.y<-qnorm(as.numeric(unlist(xy160[[1]][3])),as.numeric(marginal_non_con1$estimate[1]),as.numeric(marginal_non_con1$estimate[2]))
}

if(Marginal_Dist1=="InvG"){
  con1.y<-qinvgauss(as.numeric(unlist(xy160[[1]][3])),as.numeric(marginal_non_con1$estimate[1]),as.numeric(marginal_non_con1$estimate[2]))
}

if(Marginal_Dist1=="Logis"){
  con1.y<-qlogis(as.numeric(unlist(xy160[[1]][3])),as.numeric(marginal_non_con1$estimate[1]),as.numeric(marginal_non_con1$estimate[2]))
}

if(Marginal_Dist1=="LogN"){
  con1.y<-qlnorm(as.numeric(unlist(xy160[[1]][3])),as.numeric(marginal_non_con1$estimate[1]),as.numeric(marginal_non_con1$estimate[2]))
}

if(Marginal_Dist1=="Twe"){
  con1.y<-qtweedie(sample[,1], power=marginal_non_con1$p.max, mu=mean(Data_Con1[,con2]), phi=marginal_non_con1$phi.max)
}

if(Marginal_Dist1=="Weib"){
  con1.y<-qweibull(as.numeric(unlist(xy160[[1]][3])),as.numeric(marginal_non_con1$estimate[1]),as.numeric(marginal_non_con1$estimate[2]))
}
prediction.points<-approx(c(con1.x),c(con1.y),xout=seq(min(con1.x),max(con1.x),0.01))$y
prediction.points<-data.frame(seq(min(con1.x),max(con1.x),0.01),prediction.points)
#points(prediction.points[,1],prediction.points[,2])

prediction.points.reverse<-approx(c(con1.y),c(con1.x),xout=seq(min(con1.y),max(con1.y),0.01))$y
prediction.points.reverse<-data.frame(seq(min(con1.y),max(con1.y),0.01),prediction.points.reverse)
con1.prediction.points.ALL<-data.frame(c(prediction.points[,1],prediction.points.reverse[,2])[order((c(prediction.points[,1],prediction.points.reverse[,2])))],c(prediction.points[,2],prediction.points.reverse[,1])[order((c(prediction.points[,1],prediction.points.reverse[,2])))])

colnames(con1.prediction.points.ALL)<-c("Rainfall","OsWL")

#OsWL
u1<-BiCopCDF(u[,1], u[,2], obj2)
x<- seq(0.0001,0.9999,0.0001)
y<- seq(0.0001,0.9999,0.0001)
EL<-1/(nrow(Data_Con2)/years)

f<-function(x,y){EL/(1-x-y+u1[which(u[,1]==x & u[,2]==y)]) }
z<- outer(x,y,f)
xy160<-contourLines(x,y,z,levels= RP)

con2.y<-u2gpd(as.numeric(unlist(xy160[[1]][3])), p = 1, th=quantile(na.omit(Data[,con2]),Thres2) , sigma=exp(GPD_con2$coefficients[1]),xi= GPD_con2$coefficients[2] )

if(Marginal_Dist2=="BS"){
  con2.x<-qbisa(as.numeric(unlist(xy160[[1]][2])), as.numeric(Coef(marginal_non_con2$estimate[1])),as.numeric(Coef(marginal_non_con2$estimate[2])))
}

if(Marginal_Dist2=="Exp"){
  con2.x<-qexp(as.numeric(unlist(xy160[[1]][2])), as.numeric(marginal_non_con2$estimate[1]))
}

if(Marginal_Dist2=="Gam"){
  con2.x<-qgamma(as.numeric(unlist(xy160[[1]][2])), shape = as.numeric(marginal_non_con2$estimate[1]), rate = as.numeric(marginal_non_con2$estimate[2]))
}

if(Marginal_Dist2=="Gaus"){
  con2.x<-qinvgauss(as.numeric(unlist(xy160[[1]][2])), as.numeric(marginal_non_con2$estimate[1]), as.numeric(marginal_non_con2$estimate[2]))
}

if(Marginal_Dist2=="InvG"){
  con2.x<-qinvgauss(as.numeric(unlist(xy160[[1]][2])), as.numeric(marginal_non_con2$estimate[1]), as.numeric(marginal_non_con2$estimate[2]))
}

if(Marginal_Dist2=="LogN"){
  con2.x<-qlnorm(as.numeric(unlist(xy160[[1]][2])), as.numeric(marginal_non_con2$estimate[1]), as.numeric(marginal_non_con2$estimate[2]))
}

if(Marginal_Dist2=="Twe"){
  con2.x<-qtweedie(as.numeric(unlist(xy160[[1]][2])), power=marginal_non_con2$p.max, mu=mean(Data_Con2[,con1]), phi=marginal_non_con2$phi.max)
}

if(Marginal_Dist2=="Wei"){
  con2.x<-qweibull(as.numeric(unlist(xy160[[1]][2])), as.numeric(marginal_non_con2$estimate[1]), as.numeric(marginal_non_con2$estimate[2]))
}

prediction.points<-approx(c(con2.x),c(con2.y),xout=seq(min(con2.x),max(con2.x),0.01))$y
prediction.points<-data.frame(seq(min(con2.x),max(con2.x),0.01),prediction.points)

prediction.points.reverse<-approx(c(con2.y),c(con2.x),xout=seq(min(con2.y),max(con2.y),0.01))$y
prediction.points.reverse<-data.frame(seq(min(con2.y),max(con2.y),0.01),prediction.points.reverse)
con2.prediction.points.ALL<-data.frame(c(prediction.points[,1],prediction.points.reverse[,2])[order((c(prediction.points[,1],prediction.points.reverse[,2])))],c(prediction.points[,2],prediction.points.reverse[,1])[order((c(prediction.points[,1],prediction.points.reverse[,2])))])

colnames(con2.prediction.points.ALL)<-c("Rainfall","OsWL")

y<-numeric(length(seq(0,max(con1.prediction.points.ALL[,con1]),0.01)))
y.col<-numeric(length(seq(0,max(con1.prediction.points.ALL[,con1]),0.01)))

for(i in 1:length(seq(0,max(con1.prediction.points.ALL[,con1]),0.01))){
  j<-seq(0,max(con1.prediction.points.ALL$Rainfall),0.01)
  y[i]<-max(con1.prediction.points.ALL[,2][which(round(con1.prediction.points.ALL[,1],2)==j[i])],
            con2.prediction.points.ALL[,2][which(round(con2.prediction.points.ALL[,1],2)==j[i])])
}

y[which(y==-Inf)]<-NA
x<-seq(0,max(con1.prediction.points.ALL[,con1]),0.01)[-which(is.na(y)==TRUE)]
y.col<-seq(0,max(con1.prediction.points.ALL[,con1]),0.01)[-which(is.na(y)==TRUE)]
y<-y[-which(is.na(y)==TRUE)]

for(i in 1:length(x)){
  y.col[i]<-ifelse(any(y[i]==con1.prediction.points.ALL[which(round(con1.prediction.points.ALL[,1],2)==x[i]),2])==TRUE,4,2)
}

prediction.points.ALL<-data.frame(x,y)[-1,]
prediction.points.ALL<-data.frame(c(0,prediction.points.ALL[,1],max(prediction.points.ALL[,2])),c(max(prediction.points.ALL[,2]),prediction.points.ALL[,2],-100))
colnames(prediction.points.ALL)<-c("Rainfall","OsWL")

prediction.points.ALL<-prediction.points.ALL[!duplicated(prediction.points.ALL[,1:2]), ]
H <- Hpi(x=cop.sample[,1:2])
prediction<-kde(x=cop.sample[,1:2], H=H, eval.points=prediction.points.ALL)$estimate
k=1
lines(prediction.points.ALL[,1],prediction.points.ALL[,2],col=rev(heat.colors(150))[20:120][1],lwd=7)
points(prediction.points.ALL[,1],prediction.points.ALL[,2],col=rev(heat.colors(150))[20:120][1+100*((prediction-min(prediction))/(max(prediction)-min(prediction)))],lwd=3,pch=16,cex=1.75)
x.MostLikelyEvent.AND[k]<-as.numeric(prediction.points.ALL[which(prediction==max(prediction)),][1])
y.MostLikelyEvent.AND[k]<-as.numeric(prediction.points.ALL[which(prediction==max(prediction)),][2])
points(x.MostLikelyEvent.AND[k],y.MostLikelyEvent.AND[k],pch=18,cex=1.75)

x.full.dependence[k]<-max(x)
y.full.dependence[k]<-max(y[-1])
points(x.full.dependence[k],y.full.dependence[k],pch=17,cex=1.75)

FullDependence<-data.frame(x.full.dependence,y.full.dependence)
colnames(FullDependence)<-c("Rainfall","OsWL")

MostLikelyEvent<-data.frame(x.MostLikelyEvent.AND,y.MostLikelyEvent.AND)
colnames(MostLikelyEvent)<-c("Rainfall","OsWL")


sample.AND<-sample(1:length(prediction),size = N_Ensemble, prob=prediction)
Ensemble <- data.frame(prediction.points.ALL[sample.AND,])
res<-list("FullDependence" = FullDependence, "MostLikelyEvent" = MostLikelyEvent, "Ensemble"=Ensemble)
return(res)
}
