# SCRIPT SOM ENDRER PATH INNE I STATASCRIPT
#
# Idé: Forutsetter at vi kopierer dagens katalogstruktur uendret - det er vel mest sannsynlig.
# Da kan bare første del av path byttes ut.

# Lage liste over alle .do-filer i en gitt katalog, 
# opprette en underkatalog for originalscriptene,
# løkke gjennom alle scriptene:
# shell-kopiere originalscriptet til underkat (unngår å lese det inn først), 
# verifisere at kopien er opprettet,
# Åpne ett og ett script, 
# og erstatte alle paths til nåværende F med en ny rot. Samme tankegang som Kåres oppsett i KHfunctions. 
# Lagre og erstatte do-filene in situ.

# Første versjon: Tar bare filene i én katalog, som må skrives inn i scriptet.

# Andre commit: Sjekker om backupfilen finnes fra før. I så fall hopper over behandling av filen,
# for å unngå at ved andre gangs kjøring ville de endrede paths 
# overskrive originalscript-backupen med de nåværende paths.

# FØR SKARP KJØRING: 
# Sjekk logikken med \OLD-kopi. 
# Kan det ligge script med samme navn i OLD, som dermed blir overskrevet? 
# Bør jeg for sikkerhets skyld bruke et annet katalognavn, som er eksplisitt for dette?
    

    # Basics:
    # \  er escape-tegn, så den må skrives to ganger for å escape seg selv.

#===========================================================================
# VERDIER TIL FUNKSJONEN
# Hvilken katalog skal gjennomgås:
katalog <- paste("H:\\2-data\\Git\\test")

# Hvilke deler av filpath skal byttes ut? Gammel og ny string:
# Fant først hvordan de ser ut ETTER innlesing, det legges på escape-tegn så vi får '\\'!
# Dermed bygger jeg dem slik - og bruker en function til å gjøre det, så jeg slipper å skrive tekst med backslash ...
oldroot <- file.path('F:', 'Prosjekter', 'Kommunehelsa', 'PRODUKSJON', fsep = '\\')
newroot <- file.path("F:", "Forskningsprosjekter", "PDB 2455 - Folkehelseprofiler o_", "PRODUKSJON", fsep = '\\')

#---------------------------------------------------------------------------
# Kjøring:
# Lag filliste
setwd(katalog)
filliste <- list.files(pattern = "*.do$")        # Dollar er "slutten", for å utelukke ".docx"

# Opprett backupkatalog
dir.create(file.path(katalog, "OLD"))            # Warning når katalogen eksisterer fra før.

# 1.Sjekk om backupfilen finnes fra før, i så fall stopp - ikke overskriv den.
# 2.Bygg opp en kommandostring som kopierer originalfilen til backupkatalog, og kjør den som shell.
# 3.Les inn originalfilen og bytt ut gammel root med ny.
# 4.Lagre og erstatt originalfilen.
for(fil in filliste) {
    if (!file.exists(paste(".\\OLD\\", fil, sep = ""))) { 
        
        kommando <- paste("copy ", fil, " .\\OLD\\", fil, sep = "")    
        shell(kommando, translate = TRUE)               # translate snur katalogskilletegn riktig.
    
        # Sjekk at kopieringen gikk bra før resten kjøres. 
        if (file.exists(paste(".\\OLD\\", fil, sep = ""))) {
            print(paste("Behandler: ", fil))
            # Lese inn: Dette funker. 'tekst' er en data.frame.
            # I konsollen vises paths i dataene med doble \\ , men i View() vises de som originalstringen...
            tekst <- read.table(fil, header = FALSE, sep = "£", quote = "", blank.lines.skip = FALSE, 
                                comment.char = "", allowEscapes = FALSE, stringsAsFactors = FALSE)
            
            # selve tekstsubstitusjonen: Husk å oppgi variabelnavn!
            byttet <- gsub(oldroot, newroot, tekst$V1, fixed = TRUE)    # fixed: bokstavelig match, ikke regex.
            uttekst <- as.data.frame(byttet, stringsAsFactors = FALSE)
    
            # og lagre til fil - dette blir riktig (single \) når det var doble inne i "tekst".
            # Originalfilen blir overskrevet.
            write.table(uttekst, file = fil, quote = FALSE, row.names = FALSE, col.names = FALSE)
            
        } # end -if file.exists, kopieringen gikk bra-
        
    } else { print(paste("Backupfil for ", fil, " finnes fra før. Hopper over filen.", sep = "")) }
} # end -for fil in filliste-
