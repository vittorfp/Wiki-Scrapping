## Script para a raspagem do site astro.com/astro_databank
# Parte que vai indo em cada lista e olhando as pessoas ##
setwd('~/Documentos/Raspagem Astro-databank')
library(XML)
library(foreach)
library(parallel)
library(doParallel)

# Define o numero de processos paralelos que serão usados
no_cores <- 4
cl = makeCluster(no_cores, outfile="")
registerDoParallel(cl)

# Passa a variavel global e a libray xml para o contexto do cluster
clusterExport(cl, "links.problema")
a <- clusterEvalQ(cl, library(XML) )

# Descomente a linha caso vc ja tenha rodado a rotina de raspa-listas.R
load('~/listas.Rda')
#source('raspa-listas.R')

source('mina_astro.R')

# Define de qual lista vai começar a raspar
init <- 1

# Itera por todas as listas, pegando todos os links de artigos e rodando
# a funçao mina_astro de forma paralela
for(n in init:length(listas) ){
	nxt <- listas[n]
	erro <- try(pagina <- readLines(nxt) )
	if ( ! 'try-error' %in% class(erro)){
		
		pagina <- htmlParse(pagina)  # Fala com o R para entender as linhas como um doc HTML0
		page <- xmlRoot(pagina)    # Tira as coisas que não estão dentro das TAGs HTML
		
		# Captura os links de todas as pessoas da pagina
		txt <- getNodeSet(page,"/html/body/div[@id='content']/div[@id='bodyContent']/div[@id='mw-content-text']/div[@class='mw-allpages-body']/ul/li/a")
		txt <- xmlSApply(txt,xmlGetAttr,name='href')
		links <- sapply('https://www.astro.com',paste,txt, sep = "" )
		total <- length(links)
		
		print('##############################') 
		print(paste('Processando lista',  n, ':' ))
		
		# Passa a variável com todos os links para o contexto do cluster
		clusterExport(cl, "links")
		
		# Roda a mina_astro de forma paralela, salvando tudo em um dataset bonitinho
		data <- foreach(link = links[1:total], .combine = rbind)  %dopar% { 
			mina_astro(link)
		}
		
		# Salva separadamente os dados de cada página, para poder retomar caso a execução seja interrompida 
		save(data,file=paste("~/astro-data/data",n,".Rda",sep = ""))
		
	}
}

# Para o cluster. Tem que parar pq fica consumindo memoria a doidado.
stopCluster(cl)

source('junta_tudo.R')
