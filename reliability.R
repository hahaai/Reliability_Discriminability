rdf <- function(dist, ids) {
  N <- dim(dist)[1]
  if (is.null((N))) {
    stop('Invalid datatype for N')
  }
  
  uniqids <- unique(as.character(ids))
  countvec <- vector(mode="numeric",length=length(uniqids))
  
  for (i in 1:length(uniqids)) {
    countvec[i] <- sum(grepl(uniqids[i], ids))
  }
  
  scans <- max(countvec)
  rdf <- array(NaN, N*(scans-1))
  
  count <- 1
  for (i in 1:N) {
    ind <- which(grepl(ids[i],ids))
    for (j in ind) {
      if (j != i) {
        di <- dist[i,]
        di[ind] <- Inf
        d <- dist[i,j]
        rdf[count] <- 1 - (sum(di[!is.nan(di)] < d) + 0.5*sum(di[!is.nan(di)] == d)) / (N-length(ind))
        count <-  count + 1
      }
    }
  }
  return(rdf[1:count-1])
}

mnr <- function(rdf, remove_outliers=TRUE, thresh=0, output=FALSE) {
  if (remove_outliers) {
    mnr <- mean(rdf[which(rdf[!is.nan(rdf)] > thresh)])
    ol <- length(which(rdf<thresh))
    if (output) {
      print(paste('Graphs with reliability <',thresh,'(outliers):', ol))
    }
  } else {
    ol <- 0
    mnr <- mean(rdf[!is.nan(rdf)])
  }
  nopair <- length(rdf[is.nan(rdf)])
  if (output) {
    print(paste('Graphs with unique ids:',nopair))
    print(paste('Graphs available for reliability analysis:', length(rdf)-ol-nopair))
    print(paste('MNR:', mnr))
  }
  return(mnr)
}



i2c2 <- function(graphs, ids) {
  N <- dim(graphs)[1]
  if (is.null((N))) {
    stop('Invalid datatype for N')
  }
  M <- dim(graphs)[3]
  
  wsub<-matrix(0,N,N)
  csub<-apply(graphs,1:2,mean)
  wsubv<-matrix(0,N,N)
  csubv<-matrix(0,N,N)
  
  
  uniqids <- unique(as.character(ids))
  countvec <- vector(mode="numeric",length=length(uniqids))
  
  for (i in 1:length(uniqids)) {
    countvec[i] <- sum(grepl(uniqids[i], ids))
  }
  
  
  count <- 1
  for (i in 1:length(uniqids)) {
    ind <- which(grepl(uniqids[i],ids))
    wsub<-apply(graphs[,,ind],1:2,mean)
    
    
    for (j in ind) {
      wsubv<-wsubv+(graphs[,,j]-wsub)^2
      csubv<-csubv+(graphs[,,j]-csub)^2
    }
  }
  iicc<-1- sum(wsubv)/(M-length(uniqids))/sum(csubv)*(M-1)
  
  return(iicc)
}





