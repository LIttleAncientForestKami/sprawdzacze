# Sprawdzacze

to zestaw skryptów jakie przydają się by w nowym projekcie Jawowym wykonać rekonesans.

1. sprawdzian - sprawdzi podstawy projektu

## Sprawdzian

Potrzebujesz mieć repozytorium/-ria projektu w konwencji cokolwiek_sufix
Podmieniasz w pliku `raport.adoc` tytuł swoim tytułem.
Podmieniasz w pliku `sprawdzian.sh` końcówkę katalogu swoją końcówką.
Można to zrobić jednym poleceniem, bo w obu plikach sufixy są oznaczone przez `NAZWA_TUTAJ`

Potem odpalasz. 

Każde repozytorium wedle konwencji stworzone, dostanie raport.pdf zawierający:

1. informację, czy to projekt Mavenowy
2. informację, czy dało się go zbudować bez błędów

Jeśli oba powyższe punkty są spełnione, raport dodatkowo sprawdzi:

1. Obecność pliku `.gitignore` i śmieci w repo
2. Ilość migawek per autora (i poleci `.mailmap`, jeśli by było potrzebne)
3. Wyciągnie z budowy Mavenem najciekawsze informacje: ostrzeżenia, błędy, ile plików skompilowano, ile testowych, czy jest katalog z zasobami, czas budowy, czas testowania
4. Zrobi mapę pakietów (w układzie rozproszonym i tabelarycznym)
5. Zrobi mapę klas (w obu układach)
6. Mapy rozproszone zorientuje tak, by lepiej mieściły się na stronie (pejzaż, nie portret)
7. Wygeneruje PDFa z tymi informacjami
