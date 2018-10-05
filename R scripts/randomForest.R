library("randomForest")
library("plyr") # for the "arrange" function
library("rfUtilities") # to test model significance
library("caret")

set.seed(151) 
remove_rare <- function( table , cutoff_pro ) {
  row2keep <- c()
  cutoff <- ceiling( cutoff_pro * ncol(table) )  
  for ( i in 1:nrow(table) ) {
    row_nonzero <- length( which( table[ i , ]  > 0 ) ) 
    if ( row_nonzero > cutoff ) {
      row2keep <- c( row2keep , i)
    }
  }
  return( table [ row2keep , , drop=F ])
}

otu_table <- read.table("~/Downloads/otu_table_RF_tutorial.txt", sep="\t", header=T, row.names=1, stringsAsFactors=FALSE, comment.char="")  
metadata <- read.table("~/Downloads/metadata_RF_tutorial.txt", sep="\t", header=T, row.names=1, stringsAsFactors=TRUE, comment.char="")

otu_nonzero_counts <- apply(otu_table, 1, function(y) sum(length(which(y > 0))))
hist(otu_nonzero_counts, breaks=100, col="grey", main="", ylab="Number of OTUs", xlab="Number of Non-Zero Values")

otu_table_rare_removed <- remove_rare(table=otu_table, cutoff_pro=0.2)

otu_table_rare_removed_norm <- sweep(otu_table_rare_removed, 2, colSums(otu_table_rare_removed) , '/')*100

otu_table_scaled <- scale(otu_table_rare_removed_norm, center = TRUE, scale = TRUE)
otu_table_asinh_mean_centred <- scale( asinh(otu_table), center=TRUE, scale=FALSE)

otu_table_scaled_state <- data.frame(t(otu_table_scaled))
otu_table_scaled_state$state <- metadata[rownames(otu_table_scaled_state), "state"]

rownames(otu_table_scaled_IS) <- data.frame(t(otu_table_scaled))  
otu_table_scaled_IS$IS <- metadata[rownames(otu_table_scaled_IS), "IS"]  

RF_state_classify <- randomForest( x=otu_table_scaled_state[,1:(ncol(otu_table_scaled_state)-1)] , y=otu_table_scaled_state[ , ncol(otu_table_scaled_state)] , ntree=501, importance=TRUE, proximities=TRUE )
RF_IS_regress <- randomForest( x=otu_table_scaled_IS[,1:(ncol(otu_table_scaled_IS)-1)] , y=otu_table_scaled_IS[ , ncol(otu_table_scaled_IS)] , ntree=501, importance=TRUE, proximities=TRUE ) 

RF_IS_regress_sig <- rf.significance( x=RF_IS_regress ,  xdata=otu_table_scaled_IS[,1:(ncol(otu_table_scaled_IS)-1)] , nperm=1000 , ntree=501 )

fit_control <- trainControl( method = "LOOCV" )
RF_IS_regress_loocv <- train( otu_table_scaled_IS[,1:(ncol(otu_table_scaled_IS)-1)] , y=otu_table_scaled_IS[, ncol(otu_table_scaled_IS)] , method="rf", ntree=501 , tuneGrid=data.frame( mtry=215 ) , trControl=fit_control )

RF_IS_regress_imp <- as.data.frame( RF_IS_regress$importance )
RF_IS_regress_imp$features <- rownames( RF_IS_regress_imp )
RF_IS_regress_imp_sorted <- arrange( RF_IS_regress_imp  , desc(`%IncMSE`)  )
barplot(RF_IS_regress_imp_sorted$`%IncMSE`, ylab="% Increase in Mean Squared Error (Variable Importance)", main="RF Regression Variable Importance Distribution")
barplot(RF_IS_regress_imp_sorted[1:50,"%IncMSE"], names.arg=RF_IS_regress_imp_sorted[1:50,"features"] , ylab="% Increase in Mean Squared Error (Variable Importance)", las=2, ylim=c(0,0.012), main="Regression RF")  
