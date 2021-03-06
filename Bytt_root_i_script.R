# SCRIPT SOM ENDRER PATH INNE I STATASCRIPT
#
# Id�: Forutsetter at vi kopierer dagens katalogstruktur uendret - det er vel mest sannsynlig.
# Da kan bare f�rste del av path byttes ut.

# Lage liste over alle .do-filer i en gitt katalog, 
# opprette en underkatalog for originalscriptene,
# l�kke gjennom alle scriptene:
# shell-kopiere originalscriptet til underkat (unng�r � lese det inn f�rst), 
# verifisere at kopien er opprettet,
# �pne ett og ett script, 
# og erstatte alle paths til n�v�rende F med en ny rot. Samme tankegang som K�res oppsett i KHfunctions. 
# Lagre og erstatte do-filene in situ.

# F�rste versjon: Tar bare filene i �n katalog, som m� skrives inn i scriptet.

# Andre commit: Sjekker om backupfilen finnes fra f�r. I s� fall hopper over behandling av filen,
# for � unng� at ved andre gangs kj�ring ville de endrede paths 
# overskrive originalscript-backupen med de n�v�rende paths.

# F�R SKARP KJ�RING: 
# Sjekk logikken med \OLD-kopi. 
# Kan det ligge script med samme navn i OLD, som dermed blir overskrevet? 
# B�r jeg for sikkerhets skyld bruke et annet katalognavn, som er eksplisitt for dette?
    

    # Basics:
    # \  er escape-tegn, s� den m� skrives to ganger for � escape seg selv.

#===========================================================================
# VERDIER TIL FUNKSJONEN
# Hvilken katalog skal gjennomg�s:
katalog <- paste("H:\\2-data\\Git\\test")

# Hvilke deler av filpath skal byttes ut? Gammel og ny string:
# Fant f�rst hvordan de ser ut ETTER innlesing, det legges p� escape-tegn s� vi f�r '\\'!
# Dermed bygger jeg dem slik - og bruker en function til � gj�re det, s� jeg slipper � skrive tekst med backslash ...
oldroot <- file.path('F:', 'Prosjekter', 'Kommunehelsa', 'PRODUKSJON', fsep = '\\')
newroot <- file.path("F:", "Forskningsprosjekter", "PDB 2455 - Folkehelseprofiler o_", "PRODUKSJON", fsep = '\\')

#---------------------------------------------------------------------------
# Kj�ring:
# Lag filliste
setwd(katalog)
filliste <- list.files(pattern = "*.do$")        # Dollar er "slutten", for � utelukke ".docx"

# Opprett backupkatalog
dir.create(file.path(katalog, "OLD"))            # Warning n�r katalogen eksisterer fra f�r.

# 1.Sjekk om backupfilen finnes fra f�r, i s� fall stopp - ikke overskriv den.
# 2.Bygg opp en kommandostring som kopierer originalfilen til backupkatalog, og kj�r den som shell.
# 3.Les inn originalfilen og bytt ut gammel root med ny.
# 4.Lagre og erstatt originalfilen.
for(fil in filliste) {
    if (!file.exists(paste(".\\OLD\\", fil, sep = ""))) { 
        
        kommando <- paste("copy ", fil, " .\\OLD\\", fil, sep = "")    
        shell(kommando, translate = TRUE)               # translate snur katalogskilletegn riktig.
    
        # Sjekk at kopieringen gikk bra f�r resten kj�res. 
        if (file.exists(paste(".\\OLD\\", fil, sep = ""))) {
            print(paste("Behandler: ", fil))
            # Lese inn: Dette funker. 'tekst' er en data.frame.
            # I konsollen vises paths i dataene med doble \\ , men i View() vises de som originalstringen...
            tekst <- read.table(fil, header = FALSE, sep = "�", quote = "", blank.lines.skip = FALSE, 
                                comment.char = "", allowEscapes = FALSE, stringsAsFactors = FALSE)
            
            # selve tekstsubstitusjonen: Husk � oppgi variabelnavn!
            byttet <- gsub(oldroot, newroot, tekst$V1, fixed = TRUE)    # fixed: bokstavelig match, ikke regex.
            uttekst <- as.data.frame(byttet, stringsAsFactors = FALSE)
    
            # og lagre til fil - dette blir riktig (single \) n�r det var doble inne i "tekst".
            # Originalfilen blir overskrevet.
            write.table(uttekst, file = fil, quote = FALSE, row.names = FALSE, col.names = FALSE)
            
        } # end -if file.exists, kopieringen gikk bra-
        
    } else { print(paste("Backupfil for ", fil, " finnes fra f�r. Hopper over filen.", sep = "")) }
} # end -for fil in filliste-
