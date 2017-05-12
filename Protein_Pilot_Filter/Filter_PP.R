######################################################################
#FILTER_PP: 
#This script create a xml file with filted data from Protein Pilot export 
######################################################################


list.of.packages <- c("readr", "readxl","WriteXLS")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library('readr'); library('readxl'); library('WriteXLS')

#Suppress warnings globally
options(warn = -1)
print("Ejecutando... Puede tardar un poco. ")


#Count files
files_glob_peptides <- (Sys.glob("*_PeptideSummary.txt")) 
files_glob_proteins <- (Sys.glob("*_ProteinSummary.txt")) 


if (length(files_glob_peptides) != length(files_glob_proteins)) {
  print("��WARNING!! Different number of files: Protein and Peptides")
} else {
  i <- 1
  while(i <= length(files_glob_peptides)){
    
    
    #Suppress warnings globally
    options(warn = -1)
    print("Ejecutando... Puede tardar un poco. ")
    
    
    #Loading data
    # Proteins_PP <- read_delim("Y:/ENRIQUE/Filtro PP en R/17-42_Muestra 161_NCBISmMt_ProteinSummary.txt", 
    #                           "\t", escape_double = FALSE, trim_ws = TRUE)
    # 
    # Peptidos_PP <- read_delim("Y:/ENRIQUE/Filtro PP en R/17-42_Muestra 161_NCBISmMt_PeptideSummary.txt", 
    #                           "\t", escape_double = FALSE, trim_ws = TRUE)
    
    Proteins_PP <- read_delim(files_glob_proteins[i], 
                              "\t", escape_double = FALSE, trim_ws = TRUE)
    Peptidos_PP <- read_delim(files_glob_peptides[i],
                              "\t", escape_double = FALSE, trim_ws = TRUE)
    
    Peptidos_PP <- read_delim("Y:/ENRIQUE/Programas/Protein_Pilot_Filter/17-33_16-YS-PS_SPAll_PeptideSummary.txt", 
                                   "\t", escape_double = FALSE, trim_ws = TRUE)
    
    Proteins_PP <- read_delim("Y:/ENRIQUE/Programas/Protein_Pilot_Filter/17-33_16-YS-PS_SPAll_ProteinSummary.txt", 
                                   "\t", escape_double = FALSE, trim_ws = TRUE)
    
    #choose the columns that we want. 
    Proteins_PP2 <- data.frame(Proteins_PP$N,Proteins_PP$Unused,Proteins_PP$`%Cov(95)`,Proteins_PP$`Peptides(95%)`,Proteins_PP$Accession,Proteins_PP$Name,Proteins_PP$Species)
    Peptidos_PP2 <- data.frame(Peptidos_PP$N,Peptidos_PP$Unused,Peptidos_PP$`%Cov(95)`,Peptidos_PP$Accessions,Peptidos_PP$Names,Peptidos_PP$Contrib,Peptidos_PP$Conf,Peptidos_PP$Sequence,Peptidos_PP$Modifications,Peptidos_PP$Cleavages,Peptidos_PP$dMass,Peptidos_PP$`Prec MW`,Peptidos_PP$`Prec m/z`,Peptidos_PP$`Theor MW`,Peptidos_PP$`Theor m/z`,Peptidos_PP$`Theor z`,Peptidos_PP$Sc,Peptidos_PP$Spectrum,Peptidos_PP$Time)
    
    #Remove rows with REVERSED as string
    Proteins_PP3 <- Proteins_PP2[!grepl("REVERSED", Proteins_PP2$Proteins_PP.Name),]
    Peptidos_PP3 <- Peptidos_PP2[!grepl("REVERSED", Peptidos_PP2$Peptidos_PP.Names),]
    
    #Proteins_PP2[- grep("^REVERSED ", Proteins_PP2$Name),]
    #Proteins_PP2[ grep("REVERSED ", Proteins_PP2$Name, invert = TRUE) , ]
    
    #Remove rows with Unised value => 1,3
    Proteins_PP4 <- subset(Proteins_PP3, Proteins_PP3$Proteins_PP.Unused > 1.3 ) 
    Proteins_PP4 <- subset(Proteins_PP4, Proteins_PP4$Proteins_PP...Cov.95.. > 0) 
    Proteins_PP4 <- subset(Proteins_PP4, Proteins_PP4$Proteins_PP..Peptides.95... > 0)
    
    
    #Proteinas
    Peptidos_PP4 <- subset(Peptidos_PP3, Peptidos_PP3$Peptidos_PP.Unused > 1.3)
    Peptidos_PP4 <- subset(Peptidos_PP4, Peptidos_PP4$Peptidos_PP.Contrib > 0) 
    Peptidos_PP4 <- subset(Peptidos_PP4, Peptidos_PP4$Peptidos_PP.Conf > 95) 
    Peptidos_PP4 <- subset(Peptidos_PP4, Peptidos_PP4$Peptidos_PP...Cov.95.. > 0) 
    
    #Round numbers
    colnames(Proteins_PP4) <- c("N", "Unused", "%Cov(95)", "Peptides(95%)", "Accession","Name","Species")
    colnames(Peptidos_PP4) <- c("N","Unused",	"%Cov(95)",	"Accessions",	"Names",	"Contrib",	"Conf",	"Sequence",	"Modifications",	"Cleavages",	"dMass",	"Prec MW",	"Prec m/z",	"Theor MW",	"Theor m/z",	"Theor z",	"Sc",	"Spectrum",	"Time")
    
    round_df <- function(df, digits) {
      nums <- vapply(df, is.numeric, FUN.VALUE = logical(1))
      
      df[,nums] <- round(df[,nums], digits = digits)
      
      (df)
    }
    
    Proteins_PP5 <- round_df(Proteins_PP4, digits=2)
    Peptidos_PP5 <- round_df(Peptidos_PP4, digits=2)
    
    
    
    ##############
    #comparar tablas test: 
    
    duplicates <- data.frame(Peptidos_PP5$Accession)
    duplicate2 <- aggregate(list(numdup=rep(1,nrow(duplicates))), duplicates, length)
    duplicate3 <- with(duplicate2,  duplicate2[order(duplicate2$Peptidos_PP5.Accession) , ])
    
    #Protein accesion sorted
    duplicate4 <- with(Proteins_PP5,  Proteins_PP5[order(Proteins_PP5$Accession) , ])
    #Replace in protein table
    duplicate4$`Peptides(95%)` <- duplicate3$numdup
    duplicate4$Accession <- gsub("\\;.*","", duplicate4$Accession)
    
    
    
    
    #Sort columns by peptides
    Proteins_PP6 <- duplicate4[ order(-duplicate4[,4], -duplicate4[,2]), ]
    Proteins_PP6$N <- 1:nrow(Proteins_PP6)
    
    Proteins_PP6$Species <- gsub('\\d+\\.?','', Proteins_PP6$Species)


    Peptidos_PP6 <- Peptidos_PP5[order(Peptidos_PP5[,1],-Peptidos_PP5[,6]),]
    Peptidos_PP6$Accessions <- gsub("\\;.*","", Peptidos_PP6$Accessions)
    
    #Export xml
    # WriteXLS(Proteins_PP6, ExcelFileName = "Proteins_summary.xls", SheetNames = NULL, perl = "perl",
    #          verbose = FALSE, Encoding = c("UTF-8", "latin1", "cp1252"),
    #          row.names = FALSE, col.names = TRUE,
    #          AdjWidth = FALSE, AutoFilter = FALSE, BoldHeaderRow = FALSE,
    #          na = "",
    #          FreezeRow = 0, FreezeCol = 0,
    #          envir = parent.frame())
    
    
    #Check if there is any different between N and Proteins
    
    test <- data.frame(Peptidos_PP6$N)
    colnames(test) <- c("N")
    
    for (z in 1:nrow(test)){

        if (z==1){
            test$New[z] <- NA
            test$New[z] <- 1
    }
        else if (test$N[z]==test$N[z-1]){
            test$New[z] <- test$New[z-1]
        
        }
        else if (test$N[z]!=test$N[z-1]){
            test$New[z] <- test$New[z-1]+1
        }
    }
    
    Peptidos_PP6$N <- test$New
    
  
    x <- list(Proteins = data.frame(Proteins_PP6), Peptides = data.frame(Peptidos_PP6))
    WriteXLS(x, paste(gsub("*?PeptideSummary.txt","",files_glob_peptides[i]), "Summary.xlsx", sep = "", na=""), names(x))
    

    i <- i + 1
  }
}