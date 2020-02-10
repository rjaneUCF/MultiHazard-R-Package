#' Archimedean/elliptic copula model  - Simulation
#'
#' Simulating from a fitted Archimedean or elliptic copula Model. Builds on the \code{} in \code{texmex} package.
#'
#' @param Data Dataframe containing \code{n] at least partially concurrent time series. First column may be a \code{"Date"} object. Can be \code{Dataframe_Combine} output.
#' @param Marginals An \code{migpd} object containing the n-independent generalized Pareto models.
#' @param Copula An Archimedean or elliptic copula model. Can be specified as an \code{Standard_Copula_Fit} object.
#' @param mu (average) Number of events per year. Numeric vector of length one. Default is 365.25, daily data.
#' @param N Number of years worth of extremes to be simulated. Numeric vector of length one. Default 10,000 (years).
#' @return Each n-dimensional realisation is given on the transfomred \code{[0,1]^n} scale (first n columns) in the first dataframe \code{u.Sim} and on the origional scale in the second dataframe \code{x.Sim}.
#' @seealso \code{\link{HT04_Fit}}
#' @export
#' @examples
#' Standard_Copula_Sim(Data=S22.Detrend.df,Marginals=S22.GPD,Copula=S22.Gaussian,mu=365.25,N=10000)
Standard_Copula_Sim<-function(Data,Marginals,Copula,mu=365.25,N=10000){

  #Number of extreme events
  No.events<-mu*N

  if(class(Data[,1])=="Date" | class(Data[,1])=="factor"){
  #Simulating from copula on the transformed scale
  u<-rCopula(round(No.events,0), Copula)
  colnames(u)<-names(Data[2:(ncol(Data))])

  x<-matrix(0,nrow=nrow(u),ncol=ncol(u))
  for(i in 1:(ncol(Data)-1)){
    x[,i]<-as.numeric(quantile(na.omit(Data[,(i+1)]),u[,i]))
    x[which(x[,i]>(Marginals$models[i][[1]]$threshold)),i]<-u2gpd(u[which(x[,i]>Marginals$models[i][[1]]$threshold),i], p = Marginals$models[[i]]$rate, th=Marginals$models[i][[1]]$threshold, sigma=exp(Marginals$models[i][[1]]$par[1]),xi=Marginals$models[i][[1]]$par[2])
  }
  x<-data.frame(x)
  colnames(x)<-names(Data[2:(ncol(Data))])
  } else{
  #Simulating from copula on the transformed scale
  u<-rCopula(round(No.events,0), Copula)
  colnames(u)<-names(Data[1:ncol(Data)])

  x<-matrix(0,nrow=nrow(u),ncol=ncol(u))
  for(i in 1:(ncol(Data))){
      x[,i]<-as.numeric(quantile(na.omit(Data[,i]),u[,i]))
      x[which(x[,i]>(Marginals$models[i][[1]]$threshold)),i]<-u2gpd(u[which(x[,i]>Marginals$models[i][[1]]$threshold),i], p = Marginals$models[[i]]$rate, th=Marginals$models[i][[1]]$threshold, sigma=exp(Marginals$models[i][[1]]$par[1]),xi=Marginals$models[i][[1]]$par[2])
  }
  x<-data.frame(x)
  colnames(x)<-names(Data[1:ncol(Data)])
  }
  res<-list("u.Sim"=u,"x.Sim"=x)
  return(res)
}