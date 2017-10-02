
## Junta todos os arquivos da pasta e transforma em um banco só
arquivos <- dir('~/astro-data')

bd <- data.frame()
for(n in 1:163){
	d <- load(paste("~/astro-data/data",n,".Rda",sep = "") )
	bd <- rbind(bd,data)
	print(n)
}
print("Concluido! Banco de dados unificado na variável \'bd\'.")
save(bd,file="~/astro-data/bd.rda")
