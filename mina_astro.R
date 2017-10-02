## Função que pega os dados de cada pagina 
# Essa função utiliza uma variável global chamada links.problema para 
# guardar os links que deram problema. Ainda não está implementada uma
# verificação da existencia dessa variável, portanto, se ela não existir
# vai dar erro.

mina_astro <- function(link){
	
	print(link)
	# Lê o site da web, linha por linha
	erro <- try(pagina <- readLines(link) )
	if ( ! 'try-error' %in% class(erro)){
		
		pagina = htmlParse(pagina)  # Fala com o R para entender as linhas como um doc HTML0
		page = xmlRoot(pagina)    # Tira as coisas que não estão dentro das TAGs HTML
		
		# Captura uma tag especifica da pagina
		txt = getNodeSet(page,"/html/body/div[@id='content']/*/div[@id='mw-content-text']/table[@class='infobox toccolours']/tr/td/table[@bgcolor='#f9f9f9']/tr/td")
		if( !is.null(txt) ) {
			txt = xmlSApply(txt,xmlValue)
			nome = txt[1]
			genero = substr(txt[2],10,10)
		}else{
			nome <- NA
			genero <- NA
			links.problema <- c(links.problema, link)
		}	
		
		signos = getNodeSet(page,"/html/body/div[@id='content']/*/div[@id='mw-content-text']/table[@class='infobox toccolours']/tr//img")
		if( !is.null(signos) ){
			signos = xmlSApply(signos,xmlGetAttr,name='alt')
			sol <- signos[2]
			sol <- substr(sol,3,5)
			lua <- signos[4]
			lua <- substr(lua,3,5)
			asc <- signos[5]
			asc <- substr(asc,3,5)
		}else{
			sol <- NA
			lua <- NA
			asc <- NA
			links.problema <- c(links.problema, link)
		}
		
		txt <- getNodeSet(page,"/html/body/div[@id='content']/div[@id='bodyContent']/div[@id='mw-content-text']/p | 
						  /html/body/div[@id='content']/div[@id='bodyContent']/div[@id='mw-content-text']/h2| 
						  /html/body/div[@id='content']/div[@id='bodyContent']/div[@id='mw-content-text']//li")
		if( !is.null(txt) ){
			txt <- xmlSApply(txt,xmlValue)
			index <- 0
			content <- list(NA,NA,NA,NA,NA)
			for (t in txt){
				switch( t,
						"Categories"    = { index = 1;  f <- 1 },
						"Source Notes"  = { index = 2;  f <- 1 },
						"Biography"     = { index = 3;  f <- 1 },
						"Relationships" = { index = 4;  f <- 1 },
						"Events"        = { index = 5;  f <- 1 },
						{ f <- 0 }
				)
				
				if(index != 0 && f == 0){ 
					if(is.na(content[index]) ) 
						content[index] <- t
					else
						content[index] <- paste0(content[index],t)
				}
			}
			
			categories    <- content[1]
			sources       <- content[2]
			bio           <- content[3]
			relationships <- content[4]
			events        <- content[5]
			
		}else{
			categories    <- NA
			sources       <- NA
			bio           <- NA
			relationships <- NA
			events        <- NA
			links.problema <- c(links.problema, link)
		}
		
		
	}else{
		nome <- NA
		genero <- NA
		sol <- NA
		lua <- NA
		asc <- NA
		categories    <- NA
		sources       <- NA
		bio           <- NA
		relationships <- NA
		events        <- NA
		links.problema <- c(links.problema, link)
	}
	page <- data.frame(nome,genero,sol,asc,lua,bio,events,relationships,sources,categories)
	names(page) <- c('nome','genero','sol','asc','lua','bio','events','relationships','sources','categories')
	page
	}
