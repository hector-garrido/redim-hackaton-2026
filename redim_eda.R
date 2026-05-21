library(dplyr, tidyr)
library(data.table)

filename <- "/home/hector-garrido/code/github/redim-hackaton-2026/data/2018-2024.csv"
filename <- "/home/hector-garrido/code/github/redim-hackaton-2026/data/el-caracol-base-de-datos-muerte-en-calle.xlsx"
filename <- "/home/hector-garrido/code/github/redim-hackaton-2026/data/mes-2025.xlsx"
filename <- "/home/hector-garrido/code/github/redim-hackaton-2026/data/infinitas-realidades-de-derechos-de-la-ninez-y-la-adolescencia-en-mexico.csv"
filename <- "/home/hector-garrido/code/github/redim-hackaton-2026/data/base-dataton-2026.xlsx"

redim <- filename %>% 
  fread()

redim <- filename %>% 
  readxl::read_excel(sheet = "Base")

redim %>% 
  sample_n(100) %>% 
  View()

redim %>% 
  group_by(Dependencia) %>% 
  count() %>% ungroup() %>% 
  View()

redim %>% 
  select(Población, `Factor de riesgo`) %>% 
  unique() %>% View()


aux_string <- "Personas desaparecidas, no localizadas y localizadas"

redim %>% 
  filter(aux_string %in% Población) %>% 
  select(`Ciclo de vida`) %>% 
  unique()

redim %>% 
  filter(Población==aux_string) %>% 
  filter(`Ciclo de vida`=="Niñez y adolescencia (0 a 17 años)") %>% 
  tidyr::replace_na(list(Cantidad=0,Totales=0)) %>% View()
  group_by(`Ciclo de vida`) %>% 
  summarise(nom=sum(Cantidad), denom=sum(Totales)) %>% 
  ungroup() %>% 
  View()

################################################################################

redim %>% 
  filter(AÑO ==2024) %>% 
  # group_by(`ENTIDAD DE RESIDENCIA`) %>% 
  group_by(`ESTADO CONYUGAL`) %>% 
  count() %>% ungroup() %>% View()

redim %>% 
  filter(Población==aux_string) %>% 
  write.csv("omg_redim_desap.csv", row.names=F)
    
################################################################################

redim %>% 
  # filter(AÑO ==2024) %>% 
  # group_by(`ENTIDAD DE RESIDENCIA`) %>% 
  group_by(Horario) %>% 
  count() %>% ungroup() %>% View()
