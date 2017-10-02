## Script que pega todos os links das listas de todos os artigos da wiki
 
#	Tava dando um pau, pq quando ele chego no fim de todas as listas continua indo e voltando do penultimo pro ultimo
#	então eu coloquei um condicional pra ver se o ultimo link raspado não é igual ao antepenultimo, se isso ocorrer
#	é pq ja chegou no fim dos links e ele está lá quebrando cabeça. Tive que colocar um unique() no fim tbm, pq ta 
#	ficando com listas repetidas por conta do problema que eu falei ai em cima. Ta meio estranho mas roda. Tbm 
#	não usei paralelismo para a raspagem, então ta demorando um certo tempo para raspar todos os links. Nesse caso 
#	são 163 paginas. Salva o resultado em um arquivo. 

library(XML)
listas <- "https://www.astro.com/wiki/astro-databank/index.php?title=Special:AllPages&from=A"
nxt <- listas
counter <- 0
while ( !is.null(nxt) ) {
	counter <- counter + 1
	
	erro <- try(pagina <- readLines(nxt) )
	if ( ! 'try-error' %in% class(erro)){
		
		pagina <- htmlParse(pagina)  # Fala com o R para entender as linhas como um doc HTML
		page <- xmlRoot(pagina)    # Tira as coisas que não estão dentro das TAGs HTML
		
		# Captura o link do proximo item
		erro <- try( txt <- getNodeSet(page,"/html/body/div[@id='content']/div[@id='bodyContent']/*/div[@class='mw-allpages-nav']/a") )
		if ( ! 'try-error' %in% class(erro)){
			if(length(txt) >= 2){
				nxt <- paste('https://www.astro.com',xmlGetAttr(txt[[2]],name='href'), sep = "")
				listas <- c(listas,nxt)
			}else{
				nxt <- NULL
			}
		}else{
			nxt <- NULL
		}
	}else{
		nxt <- NULL
	}
	if(length(listas) >= 3){
		if( listas[length(listas)] == listas[ length(listas) - 2 ] ){
			nxt <- NULL
		} 
	}
	print(listas[length(listas)])
}


listas <- unique(listas)
save(listas,file="~/listas.Rda")
