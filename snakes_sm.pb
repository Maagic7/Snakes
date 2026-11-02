; ===========================================================================
;  FILE : snakes_sm.pb
;  NAME : Snakes 

;  DESC : Snakes Game
;  DESC : Projekt für die Programmierausbildung in Schulen
;  DESC : oder Programmierkursen. Mit Anleitung des Ausbilders
;  DESC : durchaus für Programmiereinsteiger gedacht.
;  DESC : Der Code ist extra umfangreich dokumentiert,
;  DESC : sauber in kleine verständliche Sub-Routinen unterteilt,
;  DESC : welche als einzelne Programmierübungen herausgegriffen werden
;  DESC : können. 

;  DESC : Es handelt sich um eine reine procedurale Programmierung
;  DESC : OOP (Objektorientierung wird nicht verwendet). 
;  DESC : OOP wird auch von PureBasic nicht nativ unterstützt!
;
;  DESC : Die Varibalen und Procedure Namen sind durchgehend in englisch
;  DESC : gehalten. Das hat den Vorteil, dass erfahrene Programmierer
;  DESC : den Code auch ohne Kommentare verstehen. 
;  DESC : Die Code Dokumentation ist jedoch deutsch.
;  
;  DESC : Warum gerade PureBasic und nicht Java oder C?
;  DESC : In C, Java, etc. würde man das gleiche Programm nicht
;  DESC : so kompakt und einfach hinbekommen. Man würde eine
;  DESC : Megen externer Libraries benötigen, in die man sich
;  DESC : noch zusätzlich einarbeiten muss. Für Einsteiger ist
;  DESC : ist das nur frustrierend. 
;  DESC : PureBasic ist viel näher an C als klassiche Basic Dialekte
;  DESC : und eigenet sich daher auch herrvoragend als Vorbereitung
;  DESC : auf C und Java. Bei PureBasic ist viel unnötiges
;  DESC : Getippe, wie z.B. bei PASCAL, einfach nicht nötig.
;  DESC : Um zu einen Wert um 2 zu addieren:
;  DESC : C         : i+=2;  
;  DESC : PureBasic : i+2    es geht auch i=i+2
;  DESC : Pascal    : i:=i+2;
;{
;-  Lernziele:
;   Vie wichtiger als blanke Programmierbefehle zu lernen 
;   ist, von Beginn an, sauber strukturierte Programme zu entwerfen,
;   gute Lesbarkeit zu gewährleisten, langen verwurschtelten
;   'Spaghetticode' zu vermeiden.
; 
;   Übung 1: Spiel spielen, Diskussion, Fragen, fällt was auf, gibt es Probleme
;   Übung 2: diesen Code mit dem original 'Quick and dirty Code' vergleichen.
;            Diskussion, Fragen
;   Übung 3: Grobes durchgehen durch die einzelnen Programmsektionen
;            Erklärung des Programms durch den Lehrer
; 
;
;-  PureBasic Features: 
; * PureBasic ist extrem schnell und 
; * erzeugt .EXE Dateien, die ohne Installation laufen,
; * hat alle Kontrollstrukturen moderner Programmiersprachen
; * hat extrem mächtige in die Sprache integrierte Befehle
; * z.B. für verkettete Listen, SQL-Lite Database, für 2D und 3D Grafik
; * PureBasic läuft Cross-Platform x86 x64 Prozessoern unter Windows, Linux,  
;   MacOS, sogar eine Version für den Amiga gibt es noch.
; * Ab der kommenden Version 6 läuft es auch auf dem RASPI ARM Prozessor
; * und den ARM MACs
;}
; ===========================================================================
;
; AUTHOR   :  Stefan Maag; Bavaria/Germany
; DATE     :  2022/02/20
; VERSION  :  0.6
; COMPILER :  PureBasic 6.40+  www.PureBasic.com
; ===========================================================================
; ChangeLog:  

;   01.11.2026 S.Maag
;   - Meldung bei Programmstart für: Sprite Initialiszierung fehlgeschlagen. 
;     wegen Problem unter Linux mit der Sprite Umgebung (Sprites werden nicht angezeigt)
;      
;   31.10.2026 S.Maag
;   - Die beiden seperaten Event-Loops auf eine zusammengeführt, da Purebasic
;     auf 2 Event-Loops sehr empfindlich reagiert.

;   - Crash bei DisplayTransparentSprite) unter PureBasic 6.41 behoben
;     Das Flag #PB_Sprite_AlphaBlending zwingend beim CatchSprite() im Makro Catch_Sprite_EX hinzugefügt
;     TransparentSpriteColor() für alle per CopySprite() erzeugten Richtungs-Kopien nach dem 
;     RotateSprite() neu im Videospeicher gebunden, um Transparenzverlust unter DX11/OpenGL zu verhindern

;   - Geisterglieder-Kollision nach Apfel-Verkürzung in Board_Draw() behoben
;     Schutzabfrage If \Body()\pos > \Length : Continue : EndIf eingeführt, damit geschrumpfte 
;     Schlangenglieder keine ungültigen IDs mehr im Grid-Array hinterlassen

;   - Logikfehler in StartGame() bei Spieler-Zuweisung korrigiert
;     Abfrage auf Array-Grenzen von Snakes() repariert (\SnakeID statt fälschlicherweise \Score geprüft)
;     Explizite Zuweisung von Snakes(2)\PlayerID = 2 hinzugefügt, um Schlangen-Aktivierung für P2 zu garantieren

;   - Dynamische Joystick-Auswahl beim Spielstart (#GADGET_Launch) repariert
;     Die harte Überschreibung von \eCtrlMode auf Tastatur entfernt; Steuermodus wird nun korrekt und
;     dynamisch anhand der Dropdown-Auswahl (Player 1 oder Player 2) vergeben

;   - Tasten-Input für 2-Spieler-Modus synchronisiert und optimiert
;     ExamineKeyboard() in der Keyboard()-Prozedur so platziert, dass der globale Puffer für beide 
;     Spieler lag-frei und ohne gegenseitige Blockierung der \xWaitNextMove-Flags ausgelesen wird

;   - GameOver()- und CheckGameOver()-Logik komplett wiederhergestellt
;     Zentrierte Textausgabe an dynamische Board1-Größe angepasst und Auswertung auf das neue 
;     Players()-Array umgestellt (Ermittlung von Score und Gewinner bei 2 Player bzw. Versus Matches)

;   - Daten-Löschung in Snake_Food() beschleunigt
;     Die sequentielle Suchschleife durch die Foods()-Liste durch direkten Listensprung via 
;     ChangeCurrentElement(Foods(), *TFood) und anschließendem sicheren DeleteElement(Foods(), 1) ersetzt

;   28.11.2022 S.Maag
;   - Viele Tippfehler behoben
;     #PS$ die vordefinierte Konstante für das Ordnertrennzeichen verwendet
;     statt eigene Konstante
;
;   21.02-30.03.2022 S.Maag
;   - komplette Erneuerung des Programm Codes. Vom original
;     blieb fast nichts übrig. 
;   - Zusätzliche Foods hinzugefügt. Bewegliche Foods eingeführt.
;   - detaillierte Code Dokumentation
;
;    19/20.02.2022 S.Maag
;    - original Code von Kenny Cason dokumentiert
;    - Codeupdate von PureBasic 3 auf 5.73
;    - von alter Gosub Technik auf Procedur-Technik umgestellt
;    - auf explizite Varaiblendefinition umgestellt (EnableExplicit)
;      somit werden Tippfehler in Variablen erkannt.
;    - Konstanten statt fixer Zahlen für bessere Lesbarkeit
;    - Code optimiert und Fehler behoben
; ============================================================================

;- ---------------------------------------------------------------------
;- To Do
;  ---------------------------------------------------------------------
;  

;{ ====================      M I T   L I C E N S E        ====================
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;} ============================================================================
;

EnableExplicit

;- ---------------------------------------------------------------------
;-    Constants
; ----------------------------------------------------------------------
;{ 
; in Enumerations gekapselte Konstanten werden automatisch vom Compiler
; durchnummeriert. Beginnend bei 0 oder beim angegeben Wert.

Enumeration eSnakeType        ; Typvarianten der Snakes
  #eSnakeType_invisible = 0   ; Snake ist unsichtbar, wird nicht angezeigt
  #eSnakeType_Green           ; gruen
  #eSnakeType_Yellow          ; gelb
  #eSnakeType_Orange          ; orange
  #eSnakeType_Blue            ; blau
  #eSnakeType_Teal            ; tuerkis
  #eSnakeType_Red             ; rot
  #eSnakeType_Purple          ; lila
  #eSnakeType_Ghost           ; geist
  #eSnakeType_Hippy           ; hippy
EndEnumeration
        
; Konstanten für die Bewegungsrichtung auf dem Spielfeld : 0=up 1=right 2=down 3=left
Enumeration eDirection
  #eDirection_up    
  #eDirection_right 
  #eDirection_down 
  #eDirection_left 
EndEnumeration

Enumeration eSound ; IDs der Sounds in der SoundList()
  ; Melodien, wenn Food gefangen wird
  #eSound0 = 0
  #eSound1
  #eSound2
  
  ; Hintergrundmelodien
  #eSound50 = 50
  #eSound51
  #eSound52
  #eSound53
EndEnumeration

; Konstanten für die verschiedenen Foods 1..15
Enumeration eFoodType
  #eFood_Ant = 1      ; Ameise
  #eFood_Apple        ; Apfel
  #eFood_Bee          ; Biene  
  #eFood_Bug          ; Käfer
  #eFood_Burger       ; Burger
  #eFood_Cherry       ; Kirschen
  #eFood_Crab         ; Krabbe
  #eFood_CupCake      ; Cup Cake
  #eFood_FrenchFries  ; Pommes Frites
  #eFood_Grape        ; Frucht, Trauben
  #eFood_Mouse        ; Maus
  #eFood_Mushroom     ; Pilz
  #eFood_Scorpion     ; Skorpion
  #eFood_Spider       ; Spinne
  #eFood_Turtle       ; Schildkröte 
EndEnumeration

; Konstanten für die SpriteIDs; damit wir uns nicht unendlich viele Zahlen merken müssen,
; verwenden wir aussagekräftigere Konstanten
; da wir teils für die Sprites 4 Richtungen benötigen, erzeugen wir die SpriteIDs
; mit einem Abstand von 4, wir beginnen mit 0. Es handelt sich erst einmal nur im IDs, so dass wir 
; die Sprites später in der Liste adressieren können. Für den Speicherverbrauch
; ist das nicht relevant
Enumeration eSprite 0  Step 4   ; beginnend bei 0 - Schrittweite 4
  #eSprite_Nothing ; Wert für kein Sprite (vorhanden)  ; =0
  #eSprite_body1   ; green                             ; =4
  #eSprite_body2   ; yellow                            ; =8
  #eSprite_body3   ; orange                            ; =12
  #eSprite_body4   ; blue
  #eSprite_body5   ; teal (türkis)
  #eSprite_body6   ; red
  #eSprite_body7   ; purple
  #eSprite_body8   ; ghost
  #eSprite_body9   ; hippy
    
  #eSprite_head1   ; green
  #eSprite_head2   ; yellow
  #eSprite_head3   ; orange
  #eSprite_head4   ; blue
  #eSprite_head5   ; teal (türkis)
  #eSprite_head6   ; red
  #eSprite_head7   ; purple
  #eSprite_head8   ; ghost
  #eSprite_head9   ; hippy
  
  ; Für die Foods verwenden wir immer 4 Sprites, 
  ; egal ob wir Richtungsänderung benötigen oder nicht
  #eSprite_Food_Ant     ; Ameise
  #eSprite_Food_Apple   ; Apfel
  #eSprite_Food_Bee     ; Biene  
  #eSprite_Food_Bug     ; Käfer
  #eSprite_Food_Burger  ; Burger
  #eSprite_Food_Cherry  ; Kirschen
  #eSprite_Food_Crab    ; Krabbe
  #eSprite_Food_CupCake ; Cup Cake
  #eSprite_Food_FrenchFries ; Pommes Frites
  #eSprite_Food_Grape       ; Frucht, Trauben
  #eSprite_Food_Mouse       ; Maus
  #eSprite_Food_Mushroom    ; Pilz
  #eSprite_Food_Scorpion    ; Skorpion
  #eSprite_Food_Spider      ; Spinne
  #eSprite_Food_Turtle      ; Schildkröte
  
  #eSprite_misc1 ; X (Sprite für leeres Feld)
  
  #eSprite_Wall1 ;

EndEnumeration

Enumeration eImage ; IDs für einzelnen Bilder der ImageList()
  #eImage_head1
  #eImage_head2
  #eImage_head3
  #eImage_head4
  #eImage_head5
  #eImage_head6
  #eImage_head7
  #eImage_head8
  #eImage_head9
  #eImage20 = 20  
EndEnumeration

; Debug "SpiteIDs"
; Debug  #eSprite_body1 : Debug #eSprite_head1 : Debug #eSprite_head2

Enumeration eCtrlMode       ; Konstanten für Player Control-Mode
  #eCtrlMode_Keyboard = 1   ; Steuerung mit Tastatur
  #eCtrlMode_Joystick1      ; Steuerung mit Joystick 1
  #eCtrlMode_Joystick2      ; Steuerung mit JoyStick 2
  #eCtrlMode_Mouse          ; Steuerung mit Maus
EndEnumeration

;}
 
;- ----------------------------------------------------------------------
;-  Structures and global Variables
;- ----------------------------------------------------------------------
;{

Enumeration eElement ; IDs für die möglichen Element-Typen am Feld
  #eElement_Nothing = 0 ; nichts
  #eElement_TFood       ; Food-Element vom Typ THead
  #eElement_THead       ; Snake-Head   vom Typ THead
  #eElement_TBody       ; Snake-Body   vom Typ TBody
  #eElement_TWall       ; Wand-Element vom Typ TWall 
  #eElement_BoardLimit  ; Spielfeldgrenze
EndEnumeration

Structure TPoint    ; Type Point
  x.i               ; X-Koordinate
  y.i               ; Y-Koordinate
EndStructure
    
Structure TFood ; Type Food
  x.i           ; X-Position im Spielfeld-Gitter (Pixel-Koordinaten erhält man indem man x*FieldSize\x berechnet)
  y.i           ; Y-Position im Spielfeld-Gitter 
  FoodType.i    ; Food Typ [#eFood]
  SpriteID.i    ; ID des Sprite [#eSprite]
  SoundID.i     ; ID des abzuspielenden Sounds [#eSound]
  LifeTime.i    ; Lebenszeit des Food-Elements Millisekunden [ms]
  Credits.i     ; Credits
  xMovable.i    ; Food kann wandern
  direction.i   ; 1 up 2 right 3 down 4 left -  Use #eDirection
EndStructure

Structure THead  ; Type Head (Snake\Head)
  x.i
  y.i
  SnakeID.i      ; ID der Snake, damit lässt sich das BodyElement rückverfolgen, wenn man es auf dem Spielfeld findet
  direction.i    ; 1 up 2 right 3 down 4 left -  Use #eDirection
EndStructure

Structure TBody  ; Type Body
  x.i
  y.i
  SpriteID.i     ; ID des Sprite (wird beim Erstellen eines neuen Body-Elements von \Snake\SpriteID_Body geerbt)
  SnakeID.i      ; ID der Snake, damit lässt sich das BodyElement rückverfolgen, wenn man es auf dem Spielfeld findet
  pos.i          ; Position in the Body (1= neuestes Element)
EndStructure

; Wandelemente sind bisher noch nicht implementiert
Structure TWall   ; Type Wall - Wandelement
   x.i
   y.i
   SpriteID.i     ; ID des Sprite welches die Grafik für das Wandelement enthält
EndStructure

Structure TSnake    ; Type Snake
  eSnakeType.i      ; Type/Farbe der Snake (Enumeration eSnakeType) 0 = #eSnakeTye_invisible
  Length.i          ; Länge des Snake in Elementen
  L_Add.i           ; Anzahl Längenelemente hinzufügen: bei jedem Move dann 1 Element verlängert bis L_Add=0
  Speed.i           ; aktuelle Geschwindigkeit des Snake
  PlayerID.i        ; ID bzw. Nr. des Spielers, der den Snake steuert
  Head.THead        ; Defintion des Snake-Head
  SpriteID_Body.i   ; Standard SpriteID der Body Elemente (wird an die Body()-Elemente vererbt)
  Credits.i         ; Summe der Credits die der Snake aufgesammelt hat
  xWaitNextMove.i   ; Hinweis für Tastaturabfrage: Mit nächster Tastaturabfrage warten bis nach nächstem Move 
  TmrSpeed.i        ; Timer, Zähler Speed 
  List Body.Tbody() ; Liste der Body-Elemente vom DatenTyp TBody
EndStructure

Structure TKeyIDs   ; Type ControlKeys   Steuer-Tasten des Players
  Up.i              ; KeyID move Up
  Right.i           ; KeyID move Right  
  Down.i            ; KeyID move Down
  Left.i            ; KeyID move Left
EndStructure

Structure TPlayer     ; Type Player
  Name.s              ; Name des Spielers (String)
  Score.i             ; Score (Punkte)
  HiScore.i           ; HiScore des Spielers
  SnakeID.i           ; ID bzw. Nr. der gesteuerten Snake, damit werden fliegende Übergaben der Snakes möglich
  eCtrlMode.i         ; Bedienmodus: Tastatur, Joystick, Maus
  KeysIDs.TKeyIDs     ; Tasten Codes für Snake Steuerung
EndStructure

Structure TPkdFlds    ; Type PackedFields: Hifs-Struktur um Radar-Feldbelegung in 4-Byte LONG zu packen 
  up.a                ; Feldbelegung überhalb 
  right.a             ; Feldbelegung rechts
  down.a              ; Feldbelegung unterhalb
  left.a              ; Feldbelegung links    
EndStructure

; Speicherung der Umgebung eines Feldes. Damit speichern wir die Umgebung um ein Feld
; also ausgehend von einem Feld(x,y), die 4 Belegungen der 4 Nachbarn up,right,down,left
Structure TFieldRadar ; Type FieldRadar - zur Speicherung der Umgebung eines Feldes
  StructureUnion      
    ; StructureUnion legt alle folgenden Variablendefinitionen  auf gleiche Adresse
    ; lValue und Flds sind also nur 2 verschiedene Sichten auf die gleichen Werte
    ; 1x als 4-Byte Long und 1x als 4 einzelne Bytes. Dies benutzen wir, um 
    ; die Feldbelegung rund um ein Feld als Long zu übergeben und als
    ; einzelne Felder auszuwerten.
    lValue.l          ; 4-Byte-Long
    Flds.TPkdFlds     ; Flds zerlegt in 4 einzelne Bytes  
  EndStructureUnion  
EndStructure

; ----------------------------------------------------------------------
;     B O A R D   D A T A  -  S P I E L F E L D  D A T E N
; ----------------------------------------------------------------------

#Board_StatusBar_Height = 32 ; Höhe der Statusbar des Spielfeldes (für Anzeigen Spielstand...)

Structure TBoard        ; Type Board
  Fields.TPoint
  PixelPerField.Tpoint
  Origin.Tpoint         ; Ursprung des Boards in Pixelkoordinaten
  PixelSize.Tpoint      ; Board Grösse in Pixel X,Y-Richtung = Breite,Höhe
  xShowGrid.i           ; ShowGridLines #False/#True
  GridColor.i           ; Farbe der GridLines
  BoardColor.i          ; Hintergrundfarbe Spielfeld
EndStructure

Global Board1.TBoard     ; Variable Board1 erzeugen

; Board Daten vorbelegen
With Board1
  \Fields\x = 30          ; Felder in X-Richtung [0..30]
  \Fields\y = 30          ; Felder in Y-Richtung [0..30]
  \PixelPerField\x = 32   ; Feldgröße in Pixel X - das enspricht der Größe der Sprites
  \PixelPerField\y = 32   ; Feldgröße in Pixel X
  \xShowGrid = #True      ; Show Grid Lines
  \GridColor = RGB(80,80,80) ; Farbe der Grid Linien  [grau]
  \BoardColor = RGB(0,0,0)      ; Hintergrundfarbe Board [schwarz]
EndWith

; wird verwendet um das Element zu definieren, welches auf dem Feld plaziert ist
Structure TBoardField  ; Type GridField für die einzelnen Felder des Spielfeldes
  ElementID.i         ; ID des auf dem Feld platzierten Elements #eElement_TFood, #eElement_THead, ...
  ptrElement.i        ; Pointer to Element Memory, Zeiger auf den Speicherplatz des Elements
EndStructure

; definiert das Spielfeld in Anzahl Feldern X und Y
Global Dim Grid.TBoardField(162,92)  ; Felder am Brett, 5K := 5120x2880 => X=160, Y=90; da 32x32 Pixel 

; ----------------------------------------------------------------------
;-  Game Settings
; ----------------------------------------------------------------------

Structure TGameSetup ; Type für Game Einstellungen
  xFullScreen.i
  SnakeType1.i
  SnakeType2.i
  StartSpeed.i
  NoOfPlayers.i
  MaxFoods.i
  xPaused.i             ; Spiel pausieren
  JoyStickExist.i
EndStructure

Global GameSetup.TGameSetup ; Variable mit den Game-Settings

; PureBasic erstellt Arrays immer mit 0 für das erste Element, wir verwenden
; zwecks einfacherer Zuordnung nur von 1..2
Global Dim Snakes.TSnake(2)      ; Array für Daten von Snake 0..2
Global Dim Players.TPlayer(2)    ; Array für Daten von Player 0..2
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; Common Game Variables
; ----------------------------------------------------------------------
Global Dim FoodTemplates.TFood(15)  ; Array zum vordefinieren der Foods

Global NewList Foods.TFood() ; Liste mit den Food-Elementen auf dem Spielfeld
Global NewList Wall.TWall()  ; Liste mit den Wand-Elementen

Global.i NoOfPlayers, HiScore, NumberVersus, JoystickExist, playerjoystick, Paused, pausecounter
Global.i StartSpeed, MaxFood, FoodItems, Playerwin, xGameOver, StartTime
Global.i Sound, SoundID, SoundIDnew, SoundIDold

;}

; Macro für Wertebegrenzung Min,Max
Macro LimitMinMax(Value, Min, Max)
  If Value < Min
    Value = Min
  ElseIf Value > Max
    Value = Max
  EndIf
EndMacro

; ----------------------------------------------------------------------
; Zyklische zählerbasierte Timer, CounterBasedTimers
; ----------------------------------------------------------------------

Global Dim CTmr(10) ; Counter basierte Timmer 0..10

#CTMR_100ms = 0
#CTMR_200ms = 1
#CTMR_400ms = 2
#CTMR_500ms = 3
#CTMR_800ms = 4
#CTMR_1000ms = 5
#CTMR_1500ms = 6
#CTMR_2000ms = 7
#CTMR_4000ms = 8
#CTMR_5000ms = 9
#CTMR_10000ms = 10

#CTMR_BaseTime = 10                ; Bais Zeit 10ms

Macro MACRO_CTmr(Tmr, Time_ms)
  Tmr - 1                          ; 1x BaseTime vom Timer abziehen
  If Tmr < 0                       ; Wenn < 0,
    Tmr = Time_ms / #CTMR_BaseTime ; dann auf Startwert zurücksetzen 
  EndIf 
EndMacro

Procedure CounterBasedTimers()
    ; Timer wird immer nach angegebener Zeit #NULL
    ; Abfrage für Timer abgelaufen: If NOT CTMR(#CTMR_100ms)
    MACRO_CTmr(CTmr(#CTMR_100ms), 100)
    MACRO_CTmr(CTmr(#CTMR_200ms), 200)
    MACRO_CTmr(CTmr(#CTMR_400ms), 400)
    MACRO_CTmr(CTmr(#CTMR_500ms), 500)
    MACRO_CTmr(CTmr(#CTMR_800ms), 800)
    
    MACRO_CTmr(CTmr(#CTMR_1000ms), 1000)
    MACRO_CTmr(CTmr(#CTMR_1500ms), 1500)
    MACRO_CTmr(CTmr(#CTMR_2000ms), 2000)
    MACRO_CTmr(CTmr(#CTMR_4000ms), 4000)
    MACRO_CTmr(CTmr(#CTMR_5000ms), 5000)
    MACRO_CTmr(CTmr(#CTMR_10000ms), 10000)    
EndProcedure

Procedure DrawTextXY(text.s, x, y)
; ============================================================================
; NAME: DrawTextXY
; DESC: 
; VAR(text): Der zu zeichnende Text 
; VAR(x): x Koordinate in Pixel
; VAR(y): y Koordinate in Pixel
; RET: -
; ============================================================================
  StartDrawing(ScreenOutput())
  DrawingMode(1)
  BackColor(RGB(0,0,0))
  FrontColor(RGB(255, 255, 255))
  DrawText(x,y,text)
  StopDrawing()
EndProcedure

; ============================================================================
; NAME: Catch_Sprite_EX
; DESC: lädt ein Sprite in einer oder 4 Richtungen (up, right, down, left)
; DESC: das Sprite wird jeweils um 90° im Uhrzeigersinn gedreht
; VAR(SpriteID): SpriteID es up-Sprites
; VAR(DSptr): Data Section Pointer; Adresse im Datenbereich "?head1
; VAR(use4Dir): use 4 directions; Sprite in 4 Ausrichtungen laden
; ============================================================================

Macro Catch_Sprite_EX(_SpriteID, _DSptr, _use4Dir=#False)
  
  ; WICHTIG FÜR PB 6.xx: Das Flag #PB_Sprite_AlphaBlending zwingend beim Laden mitgeben!
  CatchSprite(_SpriteID, _DSptr, #PB_Sprite_AlphaBlending)
  TransparentSpriteColor(_SpriteID, RGB(0, 0, 0))  
  
  If _use4Dir
    ; Beim Kopieren übernimmt das neue Sprite ab PB 6.xx das Flag automatisch
    CopySprite(_SpriteID, _SpriteID + 1)
    CopySprite(_SpriteID, _SpriteID + 2)
    CopySprite(_SpriteID, _SpriteID + 3)
    
    RotateSprite(_SpriteID + 1, 90, #PB_Absolute)
    RotateSprite(_SpriteID + 2, 180, #PB_Absolute)
    RotateSprite(_SpriteID + 3, 270, #PB_Absolute)
    
    ; Transparenz für die rotierten Kopien im Videospeicher auffrischen
    TransparentSpriteColor(_SpriteID + 1, RGB(0, 0, 0))
    TransparentSpriteColor(_SpriteID + 2, RGB(0, 0, 0))
    TransparentSpriteColor(_SpriteID + 3, RGB(0, 0, 0))
  EndIf 
EndMacro

 Procedure LoadAllSprites()
; ============================================================================
; NAME: LoadAllSprites
; DESC: Lädt die Sprites aus der DataSection in den Speicher SpriteList()
; DESC: jedes Sprite braucht seine einzigartige ID (Listen-Nummer)
; DESC: Diese IDs haben wir als Konstanten bereits oben erzeugt   
; ============================================================================
  
  ; jetzt kommen die Konstanten zum Einsatz, das ist weit
  ; einfacher, als händisch hier überall korrekte Zahlen einzutragen
  ; und später dann auch die richtige Zahl wieder zu wissen!
   
  ; Macro Catch_Sprite_EX lädt Sprite in 1 (up) oder 4 Ausrichtungen (up,right,down,left) 
  ; für Sprite_Nothing laden wir ein X, damit sehen wir, wenn irgendwo etwas
  ; falsch läuft. Es taucht dann ein X am Spielfeld auf
  Catch_Sprite_EX(#eSprite_Nothing, ?misc1, #False) 
  
  ; Snake Heads
  Catch_Sprite_EX(#eSprite_head1, ?head1, #True)    ; green 
  Catch_Sprite_EX(#eSprite_head2, ?head2, #True)    ; yellow
  Catch_Sprite_EX(#eSprite_head3, ?head3, #True)    ; orange 
  Catch_Sprite_EX(#eSprite_head4, ?head4, #True)    ; blue
  Catch_Sprite_EX(#eSprite_head5, ?head5, #True)    ; teal (türkis)
  Catch_Sprite_EX(#eSprite_head6, ?head6, #True)    ; red
  Catch_Sprite_EX(#eSprite_head7, ?head7, #True)    ; purple
  Catch_Sprite_EX(#eSprite_head8, ?head8, #True)    ; ghost
  Catch_Sprite_EX(#eSprite_head9, ?head9, #True)    ; hippy
  
  ; Body-Elemente alle nur in einer Ausrichtung laden
  Catch_Sprite_EX(#eSprite_body1, ?body1, #False)   ; green
  Catch_Sprite_EX(#eSprite_body2, ?body2, #False)   ; yellow
  Catch_Sprite_EX(#eSprite_body3, ?body3, #False)   ; orange
  Catch_Sprite_EX(#eSprite_body4, ?body4, #False)   ; blue
  Catch_Sprite_EX(#eSprite_body5, ?body5, #False)   ; teal
  Catch_Sprite_EX(#eSprite_body6, ?body6, #False)   ; red
  Catch_Sprite_EX(#eSprite_body7, ?body7, #False)   ; purple
  Catch_Sprite_EX(#eSprite_body8, ?body8, #False)   ; ghost 
  Catch_Sprite_EX(#eSprite_body9, ?body9, #False)   ; hippy
  
  ; FOODs : bewegliche Foods in 4 Ausrichtungen, unbewegliche in einer Ausrichtung laden! 
  Catch_Sprite_EX(#eSprite_Food_Ant,   ?food1, #True)       ; Ameise
  Catch_Sprite_EX(#eSprite_Food_Apple, ?food2, #False)      ; Apfel
  Catch_Sprite_EX(#eSprite_Food_Bee,   ?food3, #True)       ; Biene
  Catch_Sprite_EX(#eSprite_Food_Bug,   ?food4, #True)       ; Käfer
  Catch_Sprite_EX(#eSprite_Food_Burger,?food5, #False)      ; Burger
  
  Catch_Sprite_EX(#eSprite_Food_Cherry, ?food6, #False)     ; Kirschen
  Catch_Sprite_EX(#eSprite_Food_Crab,   ?food7, #True)      ; Krabbe
  Catch_Sprite_EX(#eSprite_Food_CupCake,?food8, #False)     ; Cup Cake
  Catch_Sprite_EX(#eSprite_Food_FrenchFries, ?food9, #False); Pommes Frites
  Catch_Sprite_EX(#eSprite_Food_Grape,  ?food10, #False)    ; Trauben
  
  Catch_Sprite_EX(#eSprite_Food_Mouse,    ?food11, #True)   ; Maus
  Catch_Sprite_EX(#eSprite_Food_Mushroom, ?food12, #False)  ; Pilz
  Catch_Sprite_EX(#eSprite_Food_Scorpion, ?food13, #True)   ; Skorpion
  Catch_Sprite_EX(#eSprite_Food_Spider,   ?food14, #True)   ; Spinne
  Catch_Sprite_EX(#eSprite_Food_Turtle,   ?food15, #True)   ; Schildkröte

  Catch_Sprite_EX(#eSprite_misc1, ?misc1, #False)
  
  Catch_Sprite_EX(#eSprite_Wall1, ?wall1, #False)
  
EndProcedure 

Procedure LoadAllImages()
; ============================================================================
; NAME: LoadAllImages
; DESC: Lädt die Images aus der DataSection in den Speicher, ImageList()
; DESC: Diese Bilder werden später im Menu-Window dargestellt
; ============================================================================
  
   CatchImage(#eImage_head1, ?head1)    
   CatchImage(#eImage_head2, ?head2)
   CatchImage(#eImage_head3, ?head3)
   CatchImage(#eImage_head4, ?head4)
   CatchImage(#eImage_head5, ?head5)
   CatchImage(#eImage_head6, ?head6)
   CatchImage(#eImage_head7, ?head7)
   CatchImage(#eImage_head8, ?head8)  
   CatchImage(#eImage_head9, ?head9)
   
   CatchImage(#eImage20,?misc1) 
EndProcedure

Procedure Init_FoodTemplates()
; ============================================================================
; NAME: Init_FoodTemplates
; DESC: Initialisieren des FoodTemplate Array
; DESC: Vordefinieren der Food-Daten, so dass diese dann später
; DESC: beim Erstellen neuer Food-Elements aus den Templates kopiert
; DESC: werden können
; ============================================================================
  
  ; ----------------------------------------------------------------------
  ; Food 1 : Ameise
  ; ----------------------------------------------------------------------
  With FoodTemplates(1)   ; Food(1) Struktur öffnen
    \SpriteID = #eSprite_Food_Ant
    \FoodType = #eFood_Ant
    \Credits = 10
    \LifeTime = 50000     ; Basic LifeTime in [ms]
    \SoundID = #eSound0   ; Sound der beim fangen abgespielt wird
    \xMovable = #True
  EndWith  
  ; ----------------------------------------------------------------------
  ; Food 2 : Apfel
  ; ---------------------------------------------------------------------- 
  With FoodTemplates(2) 
    \SpriteID = #eSprite_Food_Apple
    \FoodType = #eFood_Apple
    \Credits = 10
    \LifeTime = 10000   
    \SoundID = #eSound1  
    \xMovable = #False
 EndWith
  ; ----------------------------------------------------------------------
  ; Food 3 : Biene
  ; ----------------------------------------------------------------------
  With FoodTemplates(3) ; Food(3) Struktur öffnen
    \SpriteID = #eSprite_Food_Bee
    \FoodType = #eFood_Bee
    \Credits = 10
    \LifeTime = 50000   
    \SoundID = #eSound2
     \xMovable = #True
  EndWith 
  ; ----------------------------------------------------------------------
  ; Food 4 : Käfer
  ; ---------------------------------------------------------------------- 
  With FoodTemplates(4) 
    \SpriteID = #eSprite_Food_Bug
    \FoodType = #eFood_Bug
    \Credits = 10
    \LifeTime = 50000    
    \SoundID = #eSound0
    \xMovable = #True
  EndWith
  ; ----------------------------------------------------------------------
  ; Food 5 : Burger
  ; ----------------------------------------------------------------------
  With FoodTemplates(5) 
    \SpriteID = #eSprite_Food_Burger
    \FoodType = #eFood_Burger
    \Credits = 10
    \LifeTime = 10000    
    \SoundID = #eSound2
    \xMovable = #False
  EndWith
  ; ----------------------------------------------------------------------
  ; Food 6 : Kirschen
  ; ----------------------------------------------------------------------
  With FoodTemplates(6) 
    \SpriteID = #eSprite_Food_Cherry  
    \FoodType = #eFood_Cherry
    \Credits = 10
    \LifeTime = 10000    
    \SoundID = #eSound2
    \xMovable = #False
  EndWith
  ; ----------------------------------------------------------------------
  ; Food 7 : Krabbe
  ; ----------------------------------------------------------------------
  With FoodTemplates(7) 
    \SpriteID = #eSprite_Food_Crab  
    \FoodType = #eFood_Crab
    \Credits = 10
    \LifeTime = 50000    
    \SoundID = #eSound2
     \xMovable = #True
  EndWith 
  ; ----------------------------------------------------------------------
  ; Food 8 : Cup Cake
  ; ----------------------------------------------------------------------
  With FoodTemplates(8) 
    \SpriteID = #eSprite_Food_CupCake  
    \FoodType = #eFood_CupCake
    \Credits = 10
    \LifeTime = 10000    
    \SoundID = #eSound2
    \xMovable = #False
  EndWith  
  ; ----------------------------------------------------------------------
  ; Food 9 : Pommes Frites
  ; ----------------------------------------------------------------------
  With FoodTemplates(9) 
    \SpriteID = #eSprite_Food_FrenchFries  
    \FoodType = #eFood_FrenchFries
    \Credits = 10
    \LifeTime = 10000    
    \SoundID = #eSound2
     \xMovable = #False
  EndWith
  ; ----------------------------------------------------------------------
  ; Food 10 : Trauben
  ; ----------------------------------------------------------------------
  With FoodTemplates(10) 
    \SpriteID = #eSprite_Food_Grape 
    \FoodType = #eFood_Grape
    \Credits = 10
    \LifeTime = 10000    
    \SoundID = #eSound2
    \xMovable = #False
  EndWith
  ; ----------------------------------------------------------------------
  ; Food 11 : Maus
  ; ----------------------------------------------------------------------
  With FoodTemplates(11) 
    \SpriteID = #eSprite_Food_Mouse  
    \FoodType = #eFood_Mouse
    \Credits = 10
    \LifeTime = 50000  
    \SoundID = #eSound2
    \xMovable = #True
  EndWith 
  ; ----------------------------------------------------------------------
  ; Food 12 : Pilz
  ; ----------------------------------------------------------------------
  With FoodTemplates(12) 
    \SpriteID = #eSprite_Food_Mushroom
    \FoodType = #eFood_Mushroom
    \Credits = 10
    \LifeTime = 10000   
    \SoundID = #eSound2
    \xMovable = #False
  EndWith
  ; ----------------------------------------------------------------------
  ; Food 13 : Skorpion
  ; ----------------------------------------------------------------------
  With FoodTemplates(13) 
    \SpriteID = #eSprite_Food_Scorpion
    \FoodType = #eFood_Scorpion
    \Credits = 10
    \LifeTime = 50000   
    \SoundID = #eSound2
    \xMovable = #True
  EndWith  
  ; ----------------------------------------------------------------------
  ; Food 14 : Spinne
  ; ----------------------------------------------------------------------
  With FoodTemplates(14) 
    \SpriteID = #eSprite_Food_Spider
    \FoodType = #eFood_Spider
    \Credits = 10
    \LifeTime = 50000   
    \SoundID = #eSound2
    \xMovable = #True
  EndWith
  ; ----------------------------------------------------------------------
  ; Food 15 : Schildkröte
  ; ----------------------------------------------------------------------
  With FoodTemplates(15) 
    \SpriteID = #eSprite_Food_Turtle
    \FoodType = #eFood_Turtle
    \Credits = 10
    \LifeTime = 50000   
    \SoundID = #eSound2
    \xMovable = #True
  EndWith

EndProcedure
 
Procedure LoadSnakeSounds()
; ============================================================================
; NAME: LoadSnakeSounds
; DESC: Lädt die Sounds aus der DataSection in den Speicher, SoundList()
; DESC: mit PlaySpund(#eSound0) kann der Sound dann abgespielt werden
; ============================================================================
  
   ; Food Sounds, wenn ein Food-Element gefressen wird
   CatchSound(#eSound0, ?sound0)
   CatchSound(#eSound1, ?sound1)
   CatchSound(#eSound2, ?sound2)
   
   ; Begleitmusik
   CatchSound(#eSound50, ?sound50) ; MusicA
   CatchSound(#eSound51, ?sound51) ; MusicB
   CatchSound(#eSound52, ?sound52) ; MusicC
   CatchSound(#eSound53, ?sound53) ; MusicD
EndProcedure

Procedure GetSpriteID_head(eSnakeType)
; ============================================================================
; NAME: GetSpriteID_head
; DESC: ermittelt die SpriteID des Snake-head zum angegeben SnakeType
; VAR(eSnakeType): SnakeType Typ/Farbe der Snake
; RET: SpriteID - Eintragsnummer des Sprite in der SpriteList()
; ============================================================================
 Protected ID
  
 Select eSnakeType
    Case #eSnakeType_invisible
      ID = #eSprite_Nothing
      
    Case #eSnakeType_Green
      ID = #eSprite_head1
      
    Case #eSnakeType_Yellow
      ID = #eSprite_head2
      
    Case #eSnakeType_Orange
       ID = #eSprite_head3
     
    Case #eSnakeType_Blue
       ID = #eSprite_head4
     
    Case #eSnakeType_Teal
       ID = #eSprite_head5
     
    Case #eSnakeType_Red
      ID = #eSprite_head6
      
    Case #eSnakeType_Purple
      ID = #eSprite_head7
      
    Case #eSnakeType_Ghost
      ID = #eSprite_head8
      
    Case #eSnakeType_Hippy
      ID = #eSprite_head9
  EndSelect
  
  ProcedureReturn ID
EndProcedure

Procedure GetSpriteID_body(eSnakeType)
; ============================================================================
; NAME: GetSpriteID_body
; DESC: ermittelt die SpriteID des Snake-Body zum angegeben SnakeType
; VAR(eSnakeType):  SnakeType Typ/Farbe der Snake
; RET: SpriteID - Eintragsnummer des Sprite in der SpriteList()
; ============================================================================
 Protected ID
  
  Select eSnakeType
    Case #eSnakeType_invisible
      ID = #eSprite_Nothing
  
    Case #eSnakeType_Green
      ID = #eSprite_body1
      
    Case #eSnakeType_Yellow
      ID = #eSprite_body2
      
    Case #eSnakeType_Orange
       ID = #eSprite_body3
     
    Case #eSnakeType_Blue
       ID = #eSprite_body4
     
    Case #eSnakeType_Teal
       ID = #eSprite_body5
     
    Case #eSnakeType_Red
      ID = #eSprite_body6
      
    Case #eSnakeType_Purple
      ID = #eSprite_body7
      
    Case #eSnakeType_Ghost
      ID = #eSprite_body8
      
    Case #eSnakeType_Hippy
      ID = #eSprite_body9
  EndSelect
  
  ProcedureReturn ID
EndProcedure

Procedure Field_IsSnakeHead(x, y)
; ============================================================================
; NAME: IsField_SnakeHead
; DESC: Prüft ob das über x,y angegebene Feld einen Snake\Head enthält
; DESC: und gibt die zugehörige SnakeID zurück
; VAR(x): X-Pos Feld in Grid()
; VAR(y): Y-Pos Feld in Grind()
; RET:   SnakeID oder 0, wenn kein Snake\Head
; ============================================================================

  Protected *THead.THead      ; Pointer auf Typ Head
  Protected GridElement, ret
  
  If x >=0 And x <= Board1\Fields\x
    If y >=0 And y <= Board1\Fields\y
      
      GridElement=Grid(x, y)\ElementID  ; ElementID des betroffenen Feldes aus dem Grid-Array lesen
      
      If GridElement = #eElement_THead
        *THead = Grid(x, y)\ptrElement  ; den im Grid gespeicherten Pointer des Head-Elements auf Stuktur-Pointer 
        If *THead                       ; Wenn Pointer nicht 0
          ret = *THead\SnakeID          ; SnakeID, des auf dem Feld befindlichen Head
        EndIf
      EndIf
    EndIf
  EndIf
  ProcedureReturn ret ; 0 or SnakeID 
EndProcedure

Procedure Field_IsEmpty(x,y)
; ============================================================================
; NAME: Field_IsEmpty
; DESC: Prüft ob das über x,y angegebene Feld leer ist
; VAR(x): X-Pos Feld in Grid()
; VAR(y): Y-Pos Feld in Grind()
; RET:   #True wenn leer
; ============================================================================

  Protected GridElement, ret
  
  ret = #True
  If x >=0 And x <= Board1\Fields\x      ; Überprüfung auf die Grenzen des
    If y >=0 And y <= Board1\Fields\y     ; Spielfeldes für x und y
      
      GridElement=Grid(x, y)\ElementID ; ElementID des betroffenen Feldes aus dem Grid-Array lesen
      
      If GridElement <> #eElement_Nothing ; (=0) Feld enthält kein Element, ist also leer
        ret = #False                      ; Rückgabewert #True für leeres Feld
      EndIf
    Else
      ret = #False
    EndIf
  Else
    ret = #False   
  EndIf
  ProcedureReturn ret ; #True if FieldIsEmpty
EndProcedure

Procedure Field_IsOnBoard(x,y)
; ============================================================================
; NAME: Field_IsOnBoard
; DESC: Prüft ob das über x,y angegebene Feld auf dem aktuellen
; DESC: Spielfeld liegt 
; VAR(x): X-Pos Feld in Grid()
; VAR(y): Y-Pos Feld in Grind()
; RET:   #True wenn leer
; ============================================================================
  Protected ret
  
  If x >= 0 And x <= Board1\Fields\x
    If y >= 0 And y <= Board1\Fields\y
      ret = #True
    EndIf
  EndIf
  ProcedureReturn ret
EndProcedure

Procedure.l Field_Radar(x, y)  ; TFieldRadar
; ============================================================================
; NAME: Field_Radar
; DESC: Prüft alle 4 Felder rund um das angegebene Feld und gibt
; DESC: deren Belegung als 4Byte packed Long zurück.
; VAR(x): X-Pos Feld in Grid()
; VAR(y): Y-Pos Feld in Grid()
; RET: 4-Byte packed Long Feldbelegung(up,right,down,left) .TFieldRadar   
; ============================================================================
  
  ; radar Variable als .TFieldRadar ist eine UnionStructure, welche es
  ; ermoeglicht, dass man auf 4Bytes einzeln und als gesamtes zugreifen kann
  Protected radar.TFieldRadar  
  Protected mX, mY
  
  ; so kann man FieldRadar anwenden
  ; If Field_Radar(x,y) = 0 => alle Felder rundrum sind unbelegt
  ; oder
  ; ret = FieldRadar(x,y)
  ; If ret\Flds\B0 = #eElement_TFood => oberhalb des Feldes(x,y) befindet sich ein Food
  
  ; Belegung der 4 Nachbarfelder aus Grid() auslesen
  
  With radar
    ; up
    mY = y-1
    If mY >=0 
      \Flds\up = Grid(x, mY)\ElementID
    Else
      \Flds\up = #eElement_BoardLimit  ; EndOfBoard!; Spielfeldgrenze
    EndIf  
    
    ; right
    mX = x+1
    If mx <= Board1\Fields\x
      \Flds\right = Grid(mX, y)\ElementID
    Else
      \Flds\right = #eElement_BoardLimit  ;  EndOfBoard!; Spielfeldgrenze
    EndIf  
    
    ; down
    my = y+1
    If mY <= Board1\Fields\y
      \Flds\down = Grid(x, mY)\ElementID
    Else
      \Flds\down = #eElement_BoardLimit  ;  EndOfBoard!; Spielfeldgrenze
    EndIf
    
    ; left
    mX = x-1
    If mX >=0
      \Flds\left = Grid(mX, y)\ElementID
    Else
      \Flds\left = #eElement_BoardLimit  ;  EndOfBoard!; Spielfeldgrenze
    EndIf
  EndWith
  
  ; da wir mit TFieldRadar eine StructureUnion verwenden,
  ; können wir jetzt auf die 4-Bytes B0..B3 direkt über
  ; den Long-Wert gemeinsam zugreifen und als Rückgabewert verwenden.
  ; Da wir nur 1 Wert zurückgeben können müssen wir das so machen
  ProcedureReturn radar\lValue  ; Return the packed 4-Bytes as Long
EndProcedure

Procedure.l FieldRadar_To_ElementRadar(ElementDirection, *FieldRadar.TFieldRadar)
; ============================================================================
; NAME: FieldRadar_To_ElementRadar
; DESC: Übersetzt das Radar (Belegung der 4 Nachbarn) aus Feldsicht auf 
; DESC: das Radar aus Elementsicht unter Einbeziehung der aktuellen 
; DESC: Bewegungsrichtung
; VAR(ElementDirection): Aktuelle Direction des Elements
; VAR(*FieldRadar.TFieldRadar): Radar aus Feldsicht
; RET.TFieldRadar: Radar aus Elemntsicht 
; ============================================================================
  
  Protected ER.TFieldRadar  ; Element Radar
  
  ; das Radar aus Feldsicht, also die belegten 4-Nachbarfelder up,right,down,left
  ; umschlüsseln auf das Radar aus Elementsicht, die 4 Nachbarfelder
  ; voraus, rechts, hinten, links
  ; Dies hat den Vorteil, dass man in den Bewegungsberechnungen die Richtungen
  ; nicht immer einzeln aufschlüsseln muss und dazu noch eine Menge If
  ; Abfragen zu programmieren. 
  ; Meine erste Version war mit vielen CASE und IF. Das System mit dem
  ; RADAR aus Feld und Elementsicht ergab sich als Vereinfachung daraus.
  ; Es ist eine elegantere Lösung!
  
  ; fuer das ElementRadar verwenden wir
  ; up    = forward; vorwaerts
  ; right = right; rechts
  ; down  = reverse; rückwärts
  ; left  = left; links
  With *FieldRadar
    Select ElementDirection
      Case #eDirection_up
        ; bei Direction up ist, passt die Elementausrichtung zur Feldausrichtung
        ; vvorwärts = up  - fwd=up 
        ER\lValue = \lValue     
        
      Case #eDirection_right        
        ER\Flds\up = \Flds\right    ; fwd=right
        ER\Flds\right = \Flds\down
        ER\Flds\down = \Flds\left
        ER\Flds\left = \Flds\up
       
      Case #eDirection_down         
        ER\Flds\up = \Flds\down     ; fwd=down
        ER\Flds\right = \Flds\left
        ER\Flds\down = \Flds\up
        ER\Flds\left = \Flds\right
        
      Case #eDirection_left         
        ER\Flds\up = \Flds\left     ; fwd=left
        ER\Flds\right = \Flds\up
        ER\Flds\down = \Flds\right
        ER\Flds\left = \Flds\down
        
    EndSelect
  EndWith
  
   ProcedureReturn ER\lValue    ; 4-Byte Element Radar
EndProcedure

Procedure Field_AddPosX(Xpos, delta)
; ============================================================================
; NAME: Field_AddPosX
; DESC: delta zur Feldpostion addieren (Xpos+delta)
; DESC: Das Ergebnis wird auf die Spielfeldgröße begrenzt,
; DESC: wobei es eine umlaufende Begrenzung ist. D.h. bei Überlauf geht
; DESC: bei 0 weiter
; RET : Xpos + delta [0..\Board\Fields\x] umlaufende Begrenzung
; ============================================================================
  Protected ret 
  
  ret = Xpos + delta
  
  ; hier die Ueberprüfung auf die Feldgrenzen. Im Gegensatz zu der
  ; TrunRight, TurnLeft Funktion, kann man hier nicht mit & Board1\Fields\x
  ; den Bereich begrenzen, da wir mit der Anzahl der Felder nicht genau
  ; einen voll ausgenutzten Bit-Bereich treffen. Wir müssen mit If
  ; die Grenzen abfragen und den Überlauf verwalten.
  If ret > Board1\Fields\x  ; Überlauf positiv
    ret = 0
  ElseIf ret < 0            ; Überlauf negativ
    ret = Board1\Fields\x
  EndIf  
  ProcedureReturn ret
EndProcedure

Procedure Field_AddPosY(Ypos, delta)
; ============================================================================
; NAME: Field_AddPosY
; DESC: delta zur Feldpostion addieren (Ypos+delta)
; DESC: Das Ergebnis wird auf die Spielfeldgröße begrenzt,
; DESC: wobei es eine umlaufende Begrenzung ist. D.h. bei Überlauf geht
; DESC: bei 0 weiter
; RET : Ypos + delta [0..\Board\Fields\y] umlaufende Begrenzung
; ============================================================================
  Protected ret 

  ret= Ypos + delta
  ; Überlauf prüfen und handhaben
  If ret > Board1\Fields\y ; Überlauf positiv
    ret = 0
  ElseIf ret < 0           ; Überlauf negativ
    ret = Board1\Fields\y
  EndIf  
  ProcedureReturn ret  
EndProcedure

Procedure Direction_TrunRight(actDirection)
; ============================================================================
; NAME: Direction_TrunRight
; DESC: Richtung von Elementen nach rechts drehen 
; VAR(actDirection): aktuelle Richtung des Elements 
; RET:  neue Richtung des Elements (0:up,1:right,2:down,3:left)
; ============================================================================
  
  ; wir verwenden [0..3] für die 4 Richtungen (0:up,1:right,2:down,3:left)
  ; wenn wir immer nur 1 addieren, würden wir irgendwann >3 werden, was
  ; keine gültige Richtung mehr darstellt. Wir müssen also die Richtungen
  ; immer auf 0..3 begrenzen. Das könnte man mit If-Abfragen machen.
  ; da wir aber mit der größten Zahl 3 binär genau 2 Bits(3 = %0011) belegen,
  ; können wir durch einen binären AND Befehl (in PureBasic '&'), unseren
  ; Wert korrekt auf 2 Bits begrenzen. Das funktioniert nur, wenn unser
  ; Zahlenbereich genau alle Bits eines Bereichs nutzt.  z.B. (3,7,15,31,63,127,255, ...)
  ; Bei anderen Zahlenbereichen muss man mit If Abfragen arbeiten
  ProcedureReturn (actDirection + 1) & 3 ; &3 begrenzt Addition auf 2 Bits [0..3]
EndProcedure

Procedure Direction_TrunLeft(actDirection)
; ============================================================================
; NAME: Direction_TrunLeft
; DESC: Richtung von Elementen nach links drehen 
; VAR(actDirection): aktuelle Richtung des Elements 
; RET:  neue Richtung des Elements (0:up,1:right,2:down,3:left)
; ============================================================================
  ProcedureReturn (actDirection - 1) & 3 ; &3 begrenzt Addition auf 2 Bits [0..3]
EndProcedure

Procedure Direction_TurnToFree(actDirection, *ElementRadar.TFieldRadar)
; ============================================================================
; NAME: Direction_TurnToFree
; DESC: Richtung von Elementen auf frei Richtung drehen
; DESC: bevorzugt links, rechts, Ist links und rechts belegt, dann
; DESC: auf gegenüberliegende Richtung (umkehren). Ist sowohl links
; DESC: wie rechts frei, wird zufällig ausgewählt 
; VAR(actDirection): aktuelle Richtung des Elements 
; VAR(*ElementRadar.TFieldRadar): Belegung der Nachbarfelder aus Element sicht
; RET: neue Richtung des Elements (0:up,1:right,2:down,3:left)
; ============================================================================
  
  Protected newDirection
  
  With *ElementRadar
    newDirection = actDirection
    If \Flds\left = 0 And \Flds\right = 0
      If Random(1)
        newDirection = Direction_TrunLeft(actDirection)
      Else
        newDirection = Direction_TrunRight(actDirection)
      EndIf  
    ElseIf \Flds\left=0 
      newDirection = Direction_TrunLeft(actDirection)
    ElseIf \Flds\right=0
      newDirection = Direction_TrunRight(actDirection)
    ElseIf \Flds\down = 0
      newDirection = (actDirection+2) & 3
    EndIf      
  EndWith
  
  ProcedureReturn newDirection  
EndProcedure
 

;- ----------------------------------------------------------------------
;-                    S N A K E   F U N C T I O N S
;- ----------------------------------------------------------------------
;{

Procedure Snake_Move(SnakeID)
; ============================================================================
; NAME: Snake_Move
; DESC: Bewegt Snake um 1 Feld auf dem Brett weiter, je nach Ausrichtung
; DESC: des Kopfes up, right, down, left
; VAR(SnakeID):  Snake-ID 
; RET: -
; ============================================================================
  

  If (SnakeID >0) And (SnakeID <= ArraySize(Snakes()))
    ; Debug "Snake Move : " + Str(SnakeID) 
        
    With Snakes(SnakeID)        ; Snakes Structure öffenen
      AddElement(\Body())       ; neues Body-Element hinzufügen
      \Body()\x = \Head\x       ; neues Body-Element bekommt Koordinaten
      \Body()\y = \Head\y       ; vom Kopf
      \Body()\pos = 1           ; Pos des Body-Elements, mit 1 Position Head starten, wird am Ende der Procedure um 1 weiter geschaltet
      \Body()\SnakeID=SnakeID   ; Referenz: Zugeöhrigkeit zu Snake()
      \Body()\SpriteID =\SpriteID_Body  ; Standard SpriteID für die BodyElemente aus Snake-Defintion übernehmen
            
      ; je nach aktuelle Bewegungsrichtung des Kopfes, Kopf um 1 Feld weiter
      Select \head\direction
        Case #eDirection_up
          \Head\y= Field_AddPosY(\Head\y, -1) ; Addtion mit Berücksichtigung der Spielfeldgröße
        Case #eDirection_right
          \Head\x= Field_AddPosX(\Head\x, 1)
        Case #eDirection_down
          \Head\y= Field_AddPosY(\Head\y, 1)
        Case #eDirection_left
          \Head\x= Field_AddPosX(\Head\x, -1)
      EndSelect
                 
      ; hier werden alle Bodyelemente durchlaufen und jeweils um 1 in der Position 
      ; weitergeschoben. Unser neu erzeugtes Body-Element auf Pos=1 wird so gleich
      ; auf Position 2 hinter dem Kopf geschoben. 
      If ListSize(\Body())
        ResetList(\Body())
        While NextElement(\Body())  ; alle BodyElemente durchlaufen
          \Body()\pos + 1
          If \Body()\pos > \Length
            DeleteElement(\Body())
          EndIf
        Wend 
      EndIf
      
      ; jetzt müssen wir noch die Tastaturabfrage für den Snake wieder freigeben
      ; Die Tastaturabfrage wird immer gesperrt, sobald ein Richtungsbefehl 
      ; für den Snake erkannt wurde. Dies ist nötig, da die Tastatur
      ; in sehr viel kürzeren Zeiten (ca. 10ms) abgefragt wird, als die
      ; Schlange am Bildschirm bewegt wird.
      \xWaitNextMove = #False ; RESET(Wartebefehl für neue Tastaturabfrage)
     
    EndWith     
  EndIf   
EndProcedure

Procedure Snake_Init(PlayerID, SnakeID, eSnakeType, eDirection, Length, x, y)
; ============================================================================
; NAME: Snake_Init
; DESC: Snake mit Start-Daten initialisieren
; DESC: 
; VAR(SnakeID): ID der Snake 
; RET: -
; ============================================================================
  Protected ret, I
  
  If SnakeID >0 And SnakeID <= ArraySize(Snakes())
    If PlayerID >0 And PlayerID < ArraySize(Players())
      
      With Snakes(SnakeID)
        \Head\SnakeID = SnakeID
        \Head\direction = eDirection
       
        \SpriteID_Body = GetSpriteID_body(eSnakeType)

        \PlayerID = PlayerID
        \Speed = GameSetup\StartSpeed
        \Length = Length
        
        For I = 1 To \Length-1        ; Kopf zählt bereits als 1, deshalb -1
          Snake_Move(SnakeID)  ; Bewegung mit Anfügen eines neuen Body()-Elements
        Next
      EndWith
    EndIf
  EndIf    
EndProcedure

Procedure Snake_GetHeadSpriteID(SnakeID)
 ; ============================================================================
; NAME: Snake_GetHeadSpriteID
; DESC: Ermittelt die SpriteID für Snake\Head anhand  
; DESC: des eingestellen SankeType und der aktuellen \Head\Direction
; VAR(SnakeID): ID der Snake 
; RET: SpriteID für Snake\Head
; ============================================================================

  Protected DirectionOffset, ret
  ; Direction : up=0, right=1, down=2, left=3
  With Snakes(SnakeID)
    DirectionOffset = \Head\direction      ; ergbit [0..3]
    ret = GetSpriteID_head(\eSnakeType) + DirectionOffset 
  EndWith
  ProcedureReturn ret
EndProcedure

Procedure Snake_AddCredits(SnakeID, Credits)
; ============================================================================
; NAME: Snake_AddCredits
; DESC: Fügt die Credits, die der Snake beim futtern aufsammelt 
; DESC: sowohl dem Snake als auch dem Player hinzu
; VAR(SnakeID): ID der Snake
; VAR(Credits): die Anzahl der Credits, die dem Player zugeschrieben werden
; RET: -
; ============================================================================

  Protected PlayerID
  
  If SnakeID >0 And SnakeID <= ArraySize(Snakes())
    
    With Snakes(SnakeID)
      PlayerID = \PlayerID  ; den zur Snake gehörigen Player ermitteln  
      \Credits + Credits    ; Credits zur Snake hinzufügen
    EndWith
    
    ; Korrekterweise müssen die Credits dem Player hinzugefügt werden.
    ; Die Credits an den Snake zu verteilen ist nur ein Zusatz-Feature
    ; Die Methode der getrennten Credits für Sanke & Player macht aber 
    ; theoretisch einen fliegenden Tausch von Snakes möglich, wobei
    ; die Credits für den Snake und den Player korrekt erfasst werden.
    If PlayerID > 0 And PlayerID < ArraySize(Players()) ; PlayerID gültig
      With Players(PlayerID)      ; Player-Struktur öffnen
        \Score + Credits          ; Score + Credits
        If \Score > \HiScore      ; neuer HiScore ?
          \HiScore = \Score
        EndIf
      EndWith
    EndIf
  EndIf
EndProcedure

Procedure Snake_Food(SnakeID)
  Protected *TFood.TFood      ; Pointer-Variable auf Food-Element
  
  If SnakeID > 0 And SnakeID <= ArraySize(Snakes())
    With Snakes(SnakeID)           
      
      ; Prüfen, ob es sich um ein Food-Element handelt
      If Grid(\Head\x, \Head\y)\ElementID = #eElement_TFood
        *TFood = Grid(\Head\x, \Head\y)\ptrElement 
        
        If *TFood   ; Pointer gültig
          
          ; Gemeinsame Aktionen
          Snake_AddCredits(SnakeID, *TFood\Credits) 
          PlaySound(*TFood\SoundID, #Null)          
          
          ; Futterabhängige Aktion
          ; hier können weiter Food abhängige Aktionen erfolgen 
          Select *TFood\SpriteID    ; aufsplitten welches Food
              
            Case #eSprite_Food_Ant          ; Ameise            
              \length +1 
              
            Case #eSprite_Food_Apple        ; Apfel     
               \length -1 
                
            Case #eSprite_Food_Bee          ; Biene  
                \length +1 
              
            Case #eSprite_Food_Bug          ; Käfer
                \length +1 
               
            Case #eSprite_Food_Burger       ; Burger
                \length +1 
                
            Case #eSprite_Food_Cherry       ; Kirschen
                \length +1 
                
            Case #eSprite_Food_Crab         ; Krabbe
                \length +1 
                
            Case #eSprite_Food_CupCake      ; Cup Cake
                \length +1 
                
            Case #eSprite_Food_FrenchFries  ; Pommes Frites
                \length +1 
                
            Case #eSprite_Food_Grape        ; Trauben
                \length +1 
                
            Case #eSprite_Food_Mouse        ; Maus
                \length +1 
                
            Case #eSprite_Food_Mushroom     ; Pilz
                \length +1 
                
            Case #eSprite_Food_Scorpion     ; Skorpion
                \length +1 
                
            Case #eSprite_Food_Spider       ; Spinne
                \length +1 
                
            Case  #eSprite_Food_Turtle      ; Schildkröte
                \length +1 
                
          EndSelect
          
          ; --------------------------------------------------
          ; jetz noch Food Aus der Foods() Liste löschen
          
          ; ResetList(Foods())            ; Foods(Liste()) auf Anfang
          ; While NextElement(Foods())    ; Alle Elemente der Liste durchlaufen
          ;   If Foods()\x = *TFood\x     ; wir haben das zu löschende Food-Element
          ;     If Foods()\y = *TFood\y   ; gefunden, wenn x- und y- Koordinate
          ;       DeleteElement(Foods())  ; zum Food auf dem Feld passt.
          ;       Break                   ; Food gefunden und gelöscht While Schleife verlassen
          ;     EndIf
          ;   EndIf
          ; Wend
          
          ; Perfomance FIX:
          ; Wir springen zum Element, löschen es und übergeben die '1', 
          ; damit der Listen-Pointer auf einem gültigen Nachfolgeelement landet!
          ChangeCurrentElement(Foods(), *TFood)
          DeleteElement(Foods(), 1)
          
          ; Grid-Eintrag sofort säubern
          Grid(\Head\x, \Head\y)\ElementID = #eElement_Nothing
          Grid(\Head\x, \Head\y)\ptrElement = 0
          
          ; Liste zurücksetzen, damit nachfolgende Listendurchläufe 
          ; in der Hauptschleife (z.B. Foods_LifeTime) ganz normal von vorne starten!
          ; Das könnte man auch weglassen. ForEach beginnt immer beim ersten Element
          ResetList(Foods())
          ; --------------------------------------------------
         
        EndIf
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure Snake_DetectCollision(SnakeID)
; ============================================================================
; NAME: Snake_DetectCollision
; DESC: Kollissionsüberprüfung des Snake\Head mit Element auf dem Spielfeld
; DESC: Wenn Snake auf Food trifft, dann Food verarbeiten
; DESC: Wenn Snake auf unerlaubtes Element wie Body, Head, Wall trifft,
; DESC: dann wird killed zurückgegeben
; VAR(SnakeID): ID der Snake 
; RET: Sanke killed #True if killed
; ============================================================================

  Protected killed = #False    ; Wenn Snake auf unerlaubtes Element trifft, dann killed=#TRUE
  Protected GridElement, ret
  
  If SnakeID >0 And SnakeID <= ArraySize(Snakes())
    With Snakes(SnakeID)\Head        ; Snakes\Head Structure öffenen
      GridElement=Grid(\x, \y)\ElementID ; ElementID des betroffenen Feldes aus dem Grid-Array lesen
      
      Select GridElement ; aufschlüsselen, mit was das Feld belegt ist
          
        ; leeres Feld
        Case #eElement_Nothing 
          
        ; Crash mit Body, Head, oder Wand  
        Case #eElement_TBody
          ; hier können wir entscheiden, ob wir über einen Snake\Body 
          ; hinweg kriechen können oder nicht. Wenn wir hier
          ; killed = #False belassen, dann können wir über Snake\Bodys wandern
          ; das könnte man evtl. noch als einstellbare Option einbauen
          
          killed = #True ; bei #True wäre es Ende 
          
        Case #eElement_THead
          ; prüfen, ob auf dem Feld bereits ein Head eines anderen Snakes ist
          ; dann sind die beiden Snakes mit dem Kopf zusammen gestossen
          ret = Field_IsSnakeHead(\x,\y)   
          If ret >0 And ret <> SnakeID ; Feld ist Kopf anderen Snakes
            killed = #True
          EndIf
            
        Case #eElement_TWall
            killed = #True
          
        Case #eElement_TFood
          Snake_Food(SnakeID) ; gefundes Food verarbeiten
          
      EndSelect     
    EndWith
  EndIf
  ProcedureReturn killed
EndProcedure
;}

;- ----------------------------------------------------------------------
;-                      B O A R D   F U N C T I O N S
;- ----------------------------------------------------------------------
;{

Macro Board_DeleteFood(x, y)
  Grid(x,y)\ElementID = #eElement_Nothing
  Grid(x,y)\ptrElement = 0  
EndMacro

Macro Board_PutFood(x, y, NewFood)
    Grid(x,y)\ElementID = #eElement_TFood  ; Feldbelegung mit Typ TFood im Grid eintragen
    Grid(x,y)\ptrElement = @NewFood        ; Speicheradresse (Pointer) des Body-Elements eintragen
EndMacro
  
Procedure Board_InitData()
; ============================================================================
; NAME: Board_Init
; DESC: Initalisieren der Spielfeld Daten
; DESC: Muss einemal vor dem Start des Spiels aufgerufen werden
; DESC: um evtl. geänderte Spielfeldgröße neu anzupassen
; ============================================================================
  
  With Board1
    \Origin\x=0                                     ; Koordinaten Ursprung X
    \Origin\y=#Board_StatusBar_Height               ; Koordinaten Ursprung Y
    \PixelSize\x = (\Fields\x+1) * \PixelPerField\x ; Breite in Pixel
    \PixelSize\y = (\Fields\y+1) * \PixelPerField\y ; Hoehe in Pixel
  EndWith
    
EndProcedure

Procedure Board_Draw()
; ============================================================================
; NAME: Board_Draw
; DESC: Zeichnet das Spielfeld, Schlangen, Foods und Wände komplett neu.
;       Bereinigt Geisterglieder bei Verkürzung (Äpfel).
; RET:  -
; ============================================================================

  Protected I, J     ; Laufvariablen
  Protected x, y     ; Feldkoordinaten
  Protected memSprite
  
  ClearScreen(Board1\BoardColor) ; Bildschirm komplett löschen (schwarz)
  
  ; ----------------------------------------------------------------------
  ; 1. Gesamtes Grid-Array komplett zurücksetzen
  ; Das verhindert effektiv, dass gelöschte oder geschrumpfte Schlangenglieder
  ; als "Geister-Kollisionen" im Speicher hängen bleiben.
  ; ----------------------------------------------------------------------
  For I = 0 To Board1\Fields\x
    For J = 0 To Board1\Fields\y
      Grid(I, J)\ElementID = #eElement_Nothing
      Grid(I, J)\ptrElement = 0
    Next
  Next
    
  ; ----------------------------------------------------------------------
  ; 2. Alle sichtbaren Snakes 1..max zeichnen
  ; ----------------------------------------------------------------------
  For I = 1 To ArraySize(Snakes())
    
    With Snakes(I)
      If \eSnakeType <> #eSnakeType_invisible  ; Nur zeichnen, wenn aktiv
        
        ; --- BODY ZEICHNEN ---
        If ListSize(\Body())          
          ResetList(\Body())          
          While NextElement(\Body())  
            x = \Body()\x             
            y = \Body()\y             
            
            ; KORREKTUR: Falls die Schlange durch einen Apfel geschrumpft ist,
            ; ignorieren wir Glieder, deren Position größer als die aktuelle Länge ist.
            If \Body()\pos > \Length
              Continue
            EndIf
            
            If \Body()\SpriteID
              DisplayTransparentSprite(\Body()\SpriteID, x*Board1\PixelPerField\x + Board1\Origin\x, y*Board1\PixelPerField\y + Board1\Origin\y)
            Else
              DisplayTransparentSprite(#eSprite_misc1, x*Board1\PixelPerField\x+ Board1\Origin\x, y*Board1\PixelPerField\y + Board1\Origin\y)
            EndIf
        
            Grid(x,y)\ElementID = #eElement_TBody 
            Grid(x,y)\ptrElement =  @\Body()      
          Wend                                    
        EndIf 
        
        ; --- HEAD ZEICHNEN ---
        x = \Head\x
        y = \Head\y
        DisplayTransparentSprite(Snake_GetHeadSpriteID(I), x * Board1\PixelPerField\x + Board1\Origin\x, y * Board1\PixelPerField\y + Board1\Origin\y)
        
        Grid(x, y)\ElementID = #eElement_THead
        Grid(x, y)\ptrElement = @\Head
      EndIf
    EndWith
    
  Next 
  
  ; ----------------------------------------------------------------------
  ; 3. Foods zeichnen
  ; ----------------------------------------------------------------------
  If ListSize(Foods())
    ResetList(Foods())
    With Foods()
      While NextElement(Foods())
        x = \x
        y = \y
        
        memSprite = \SpriteID
        If \xMovable 
          ; Bei wandernden Foods die Blickrichtung für die Sprite-ID addieren
          memSprite = memSprite + \direction
        EndIf
              
        DisplayTransparentSprite(memSprite, x * Board1\PixelPerField\x + Board1\Origin\x, y * Board1\PixelPerField\y + Board1\Origin\y)
        
        Grid(x, y)\ElementID = #eElement_TFood
        Grid(x, y)\ptrElement = @Foods()
        
        ; Die Lebenszeit-Verringerung wurde in die Logikschleife
        ; ausgelagert, um ein doppeltes Abziehen (Soll & Ist) zu verhindern!
      Wend
    EndWith
  EndIf
  
  ; ----------------------------------------------------------------------
  ; 4. Wall-Elemente zeichnen
  ; ----------------------------------------------------------------------
  If ListSize(Wall())
    ResetList(Wall())
    While NextElement(Wall())
      x = Wall()\x
      y = Wall()\y
      
      DisplayTransparentSprite(Wall()\SpriteID, x * Board1\PixelPerField\x + Board1\Origin\x, y * Board1\PixelPerField\y + Board1\Origin\y)
      Grid(x, y)\ElementID = #eElement_TWall
      Grid(x, y)\ptrElement = @Wall()
    Wend
  EndIf
  
  ; ----------------------------------------------------------------------
  ; 5. UI Statusleiste live zeichnen
  ; ----------------------------------------------------------------------
  DrawTextXY("P1-Score: " + Str(Players(1)\Score), 200, 0)
  If GameSetup\NoOfPlayers = 2
    DrawTextXY("P2-Score: " + Str(Players(2)\Score), 400, 0)
  EndIf
  DrawTextXY("Hi Score: " + Str(HiScore), 0, 0)
  
  ; NEU & SICHER: Wenn das Spiel pausiert ist, zeichnen wir das Wort "PAUSE" mittig auf den Screen
  If GameSetup\xPaused
    Protected CanvasWidth = Board1\PixelSize\x + Board1\Origin\x
    Protected CanvasHeight = Board1\PixelSize\y + Board1\Origin\y
    
    StartDrawing(ScreenOutput())
    DrawingMode(#PB_2DDrawing_Transparent)
    FrontColor(RGB(255, 255, 0)) ; Gelber Text für die Pause
    DrawText(CanvasWidth / 2 - TextWidth("PAUSE") / 2, CanvasHeight / 2 - 10, "PAUSE")
    StopDrawing()
  EndIf

  ; ----------------------------------------------------------------------
  ; 6. Grid Hilfslinien zeichnen
  ; ----------------------------------------------------------------------
  StartDrawing(ScreenOutput())
  
  If Board1\xShowGrid
    For I = 0 To Board1\Fields\x + 1
      Line(I * Board1\PixelPerField\x + Board1\Origin\x, Board1\Origin\y, 1, Board1\PixelSize\y, Board1\GridColor)
    Next
    
    For I = 0 To Board1\Fields\y + 1
      Line(0, I * Board1\PixelPerField\y + Board1\Origin\y, Board1\PixelSize\x, 1, Board1\GridColor)
    Next
  Else
    ; Nur den Außenrahmen zeichnen
    Line(Board1\Origin\x, Board1\Origin\y, 1, Board1\PixelSize\y, Board1\GridColor)
    Line(Board1\Origin\x + Board1\PixelSize\x, Board1\Origin\y, 1, Board1\PixelSize\y, Board1\GridColor)
    Line(Board1\Origin\x, Board1\Origin\y, Board1\PixelSize\x, 1, Board1\GridColor)
    Line(Board1\Origin\x, Board1\Origin\y + Board1\PixelSize\y, Board1\PixelSize\x, 1, Board1\GridColor)
  EndIf
  StopDrawing()

  FlipBuffers() ; Buffer flippen für flackerfreie DX11-Darstellung

EndProcedure

;}

;- ----------------------------------------------------------------------
;-                  F O O D   F U N C T I O N S
;- ----------------------------------------------------------------------
;{

Procedure Foods_AddRandomFood(NoOfFoodsToAdd, MyLifeTime_ms=0)
; ============================================================================
; NAME: AddRandomFood
; DESC: fügt ein zufällig generiertes Food-Element zur Foods()-Liste hinzu
; DESC: das Food-Element wird nur in die Liste eingefügt, nicht aber am 
; DESC: Bildschirm gezeichnet. Am Bildschirm dargestellt wir es erst
; DESC: wenn das Spielfeld neu gezeichnet wird!
; VAR(NoOfFoodsToAdd) : Anzahl der Food-Elemente, die hinzugefügt werden
; VAR(MyLifeTime_ms=0)  : LifeTime FoodElement in [ms]
;                         Angabe optional. Wenn 0, dann LifeTime von Template
; RET: *TFood Pointer auf das neue Food-Element
; ============================================================================
  Protected I, x, y, FoodID 
  Protected ready, ret, mem
  
  For I=1 To NoOfFoodsToAdd
  ; Food-Elemment hinzufügen, solange Max Anzahl Foods nicht erreicht
    If ListSize(Foods()) < GameSetup\MaxFoods
      
      AddElement(Foods()) ; neues Element an Liste anhängen
      
      ; Zufallszahl = 10x Anzahl FoodTypen. Dadurch kann man die Auftrittshäufigkeiten
      ; individuell einstellen. Würden wir nur 15 (=Anzahl FoodTypen) verwenden, taucht
      ; jedes Food gleich häufig auf. Wenn wir jedoch z.B. die Cherry's als special
      ; Credits verwenden möchten, sollte die weniger häufig auftreten
      mem = Random(150) ; Zufallszahl generieren
      
      ; hier kann durch einstellen der Bereiche, die Auftrittshäufigkeit der einzelnen Foods eingestellt werden!
      ; Im Moment ist noch alles gleichverteilt eingestellt
      If mem < 10    : FoodID =#eFood_Ant         ; 1
      ElseIf mem<20  : FoodID =#eFood_Apple       ; 2
      ElseIf mem<30  : FoodID =#eFood_Bee         ; 3
      ElseIf mem<40  : FoodID =#eFood_Bug         ; 4
      ElseIf mem<50  : FoodID =#eFood_Burger      ; 5
      ElseIf mem<60  : FoodID =#eFood_Cherry      ; 6
      ElseIf mem<70  : FoodID =#eFood_Crab        ; 7  
      ElseIf mem<80  : FoodID =#eFood_CupCake     ; 8
      ElseIf mem<90  : FoodID =#eFood_FrenchFries ; 9
      ElseIf mem<100 : FoodID =#eFood_Grape       ; 10
      ElseIf mem<110 : FoodID =#eFood_Mouse       ; 11
      ElseIf mem<120 : FoodID =#eFood_Mushroom    ; 12
      ElseIf mem<130 : FoodID =#eFood_Scorpion    ; 13
      ElseIf mem<140 : FoodID =#eFood_Spider      ; 14
      ElseIf mem<150 : FoodID =#eFood_Turtle      ; 15
      EndIf
            
      ; nun kopieren wir das entsprechende Food-Element fertig voreingestellt aus unserem
      ; FoodTemplates-Array (siehe Init_FoodTemplates)
      Foods() = FoodTemplates(FoodID) ; Food-Element mit Daten aus Vorlage-Array kopieren
      
      With Foods()
        If MyLifeTime_ms = 0
          ; Lebenszeit Food, mit etwas Zufall ausstatten, 50% vom Startwert max. drauf
          mem = \LifeTime /3
          \LifeTime = \LifeTime + Random(2 * mem) - mem ; Achtung Random [,Minimum] darf nicht negativ sein
        Else
          \LifeTime = MyLifeTime_ms
        EndIf    
        
        If \xMovable
          \direction = Random(3) ; zufällige Richtung                    
        EndIf
        
      EndWith
      
      ; neues Food-Element an zufälliger Position x,y platzieren
      Repeat
        ready = #True
        x = Random(Board1\Fields\x)  ; X-Position zufällig
        y = Random(Board1\Fields\y)  ; Y-Position zufällig
        
        ; prüfen ob Feld bereits belegt - wenn Feld nicht leer, dann ready=#False    
        If Not Field_IsEmpty(x,y) : ready = #False : EndIf
        
        ; Mindestabstand zu Haed muss 1 freies Feld sein, deshalb die 4 Felder
        ; um das ermittelte Feld auf Head-Element pruefen
        ; aber Achtung, wir sollten nicht versuchen über unser akuelles
        ; Grid hinauszulesen, das könnte Schwierigkeiten geben,
        ; deshalb muss die neue Position auf die Grenzen GridSize\x \y
        ; geprüft werden
        
        ; Field-IsSnakeHead übernimmt bereits die Prüfung auf korrekte x,y
        ; wir müssen uns also nicht extra drum kpümmern. Wenn wir
        ; über das Grid hinaus lesen, dann wird 0 zurückgegeben, was bedeuted
        ; auf dem Feld befindet sich kein Snake\Head
        If Field_IsSnakeHead(x+1,y) : ready = #False : EndIf    
        If Field_IsSnakeHead(x-1,y) : ready = #False : EndIf
        If Field_IsSnakeHead(x,y+1) : ready = #False : EndIf
        If Field_IsSnakeHead(x,y-1) : ready = #False : EndIf
         
      Until ready ; solange wiederholen, bis Gridposition frei bzw. Abstand zu Head ok
    
      Foods()\x = x ; ermittelte und überprüfte Zufallspostion dem Food-Element
      Foods()\y = y ; zuweisen
      ret =  @Foods() ; *TFood Pointer auf das neu erzeugte Food-Element als Rückgabewert 
      ; Debug "Food on: x/y " + Str(x) + "/" + Str(y) 
    EndIf
  Next
  
  ProcedureReturn ret ; *TFood falls ein Food erzeugt wurde, sonst 0
EndProcedure

Procedure Foods_Move()
; ============================================================================
; NAME: Foods_Move
; DESC: verschiebt die beweglichen Food-Elemente um 1 Feld auf dem Board
; RET:  #True, wenn ein Element Verschoben wurde. (= Befehl: neu zeichenen)
; ============================================================================
  
  Protected newX, newY, newDir
  Protected xMsgMoved   ; Meldung Food wurde bewegt; Rückgabewert für neu zeichnen
  Protected xCanMove = #True
  
  ; Radar Variable - für die Belegung der 4 Nachbarfelder des Food-Elements
  Protected FR.TFieldRadar ; Field Radar    - Radar aus Feldsicht
  Protected ER.TFieldRadar ; Element Radar  - Radar aus Element Sicht
  
  If ListSize(Foods())            ; Wenn Foods(Liste()) nicht leer
    ResetList(Foods())            ; Foods(Liste()) auf Anfang
    While NextElement(Foods())    ; Alle Elemente der Liste durchlaufen
      
      With Foods()
        If \xMovable    ; Wenn bewegliches Food-Element
          
          ; Belegung der 4 Nachbarfelder ermitteln aus Feldsicht ermitteln
          ; also up,ritht,down,left
          FR\lValue = Field_Radar(\x, \y)
          ; Belegung der 4 Nachbarfelder aus Elementsicht ermitteln
          ; also in Richtung vorwärts, rechts, links, rückwärts
          ; das ist dan abhängig von der aktuellen Bewegunsrichtung,
          ; so dass man das Radar aus Feldsicht auf Elementsicht
          ; umrechnen muss.
          ER\lValue = FieldRadar_To_ElementRadar(\direction, FR)
          
          newX = \x 
          newY = \y
         
          If ER\Flds\up        ; Feld in Bewegungsrichtung ist belegt
            If er\Flds\up = #eElement_BoardLimit
              Debug "Board Limit"
            EndIf
            
            newDir = Direction_TurnToFree(\direction, ER) ; suche freie Bewegungsrichtung
            ; Debug "newDir=" + Str(newDir) + " oldDir=" +Str(\direction)
            If newDir = \direction 
              xCanMove =#False      ; keine freie Bewegungsrichtung gefunden
            Else
              \direction = newDir   ; neue Bewegungsrichtung für Food übernehmen
            EndIf           
          EndIf
          
          If xCanMove                 ; wenn sich Food noch bewegen kann (nicht eingekesselt ist)
            Select \direction         ; dann neue Position berechnen. 1 Feld weiter
              Case #eDirection_up
                newY -1    
              Case #eDirection_right
                newX +1
              Case #eDirection_down
                newY +1
              Case #eDirection_left
                newX -1
            EndSelect
          EndIf
          
          ; ----------------------------------------------------------------------
          
          If \x <> newX Or \y <> newY        ; wenn sich Position des Food geändert hat
             If Field_IsEmpty(newX, newY)    ; ist Feld wirklich leer und noc auf dem Spielfeld
                Board_DeleteFood(\x, \y)     ; Food an alter Positon löschen
                ; Debug "Move: " + Str(\x) + "/" + Str(\y) + " -> " + Str(newX) + " /" + Str(NewY)
                \x = newX                    ; neu Position auf Food übernehmen
                \y = newY
                Board_PutFood(newX, newY, Foods())  ; Food auf Board an neuer Position eintragen
                xMsgMoved = #True             ; Meldung es hat eine Bewegung stattgefunden (=>Board neu zeichnen)
             EndIf
          EndIf  
        EndIf
      EndWith           
    Wend 
  EndIf
  
  ProcedureReturn xMsgMoved  ; Rückgabe = #TRUE wenn Board neu gezeichnet werden muss
EndProcedure

Procedure Foods_LifeTime()
; ============================================================================
; NAME: Foods_LifeTime
; DESC: Verringert die FoodLifeTime jedes in der FoodListe
; DESC: enthaltenen Food-Elements um 10ms, dem Basistatk der Main-Game-Loop
; DESC: Wenn LifeTime bei 0 angelangt ist, wird das Food-Element entfernt
; DESC: dazu wird es einfach aus der Foods() gelöscht und somit beim
; DESC: näschsten Zeichenvorgang nicht mehr angezeigt.  
; RET:  #True, wennn Element gelöscht (= Befehl: neu zeichnen)
; ============================================================================
 
  ; FoodLifeTime in der Spiel Haupt-Schleife im Basis-Zeittakt von 10ms
  ; aufrufen, damit die LifeTimes korrekt stimmen
  
  Protected ret
  
  ResetList(Foods())            ; Foods(Liste()) auf Anfang
  If ListSize(Foods())
    While NextElement(Foods())    ; Alle Elemente der Liste durchlaufen
      With Foods()
        
        \LifeTime - #CTMR_BaseTime             ; -10ms
        If \LifeTime <=0          ; LifeTime abgelaufen
          DeleteElement(Foods())  ; Food-Element löschen
          ret = #True
        EndIf
      EndWith
    Wend
  EndIf
  
  ProcedureReturn ret ; #True, wenn Element entfernt => neu Zeichnen
EndProcedure
;}

;- ----------------------------------------------------------------------
;-                  C O N T R O L   F U N C T I O N S
;- ----------------------------------------------------------------------


Procedure Keyboard()
; ============================================================================
; NAME: Keyboard
; DESC: Wertet Tastatur- und Joystick-Eingaben für alle Spieler synchron aus
; ============================================================================
  Protected I, SnakeID
  Protected CtrlMode, JsID
  Protected KC.TKeyIDs  ; Bedientasten
  
  ; WICHTIG: Den Tastaturpuffer EINMALIG für diesen Frame aktualisieren
  ExamineKeyboard()

  For I = 1 To GameSetup\NoOfPlayers
    With Players(I)  
      CtrlMode = \eCtrlMode
      SnakeID = \SnakeID
      KC = \KeysIDs
    EndWith
    
    With Snakes(SnakeID)   
      
      ; Mit xWaitNextMove warten wir, bis die letzte Aktion gezeichnet wurde
      If \xWaitNextMove = #False
        Select CtrlMode 
            
          Case #eCtrlMode_Keyboard
            ; Die Abfrage nutzt jetzt den oben sauber initialisierten Puffer
            If KeyboardPushed(KC\Up) And \Head\direction <> #eDirection_down
              \Head\direction = #eDirection_up   
              \xWaitNextMove = #True
            ElseIf KeyboardPushed(KC\Right) And \Head\direction <> #eDirection_left
              \Head\direction = #eDirection_right   
              \xWaitNextMove = #True
            ElseIf KeyboardPushed(KC\Down) And \Head\direction <> #eDirection_up
              \Head\direction = #eDirection_down   
              \xWaitNextMove = #True
            ElseIf KeyboardPushed(KC\Left) And \Head\direction <> #eDirection_right
              \Head\direction = #eDirection_left   
              \xWaitNextMove = #True
            EndIf
            
          Case #eCtrlMode_Joystick1, #eCtrlMode_Joystick2
            If CtrlMode = #eCtrlMode_Joystick1  
              JsID = 0
            Else 
              JsID = 1
            EndIf 
            
            ExamineJoystick(JsID) ; Joystickstatus aktualisieren
            
            If JoystickAxisY(JsID) = -1 And \Head\direction <> #eDirection_down
              \Head\direction = #eDirection_up   
              \xWaitNextMove = #True
            ElseIf JoystickAxisX(JsID) = 1 And \Head\direction <> #eDirection_left
              \Head\direction = #eDirection_right   
              \xWaitNextMove = #True
            ElseIf JoystickAxisY(JsID) = 1 And \Head\direction <> #eDirection_up
              \Head\direction = #eDirection_down   
              \xWaitNextMove = #True
            ElseIf JoystickAxisX(JsID) = -1 And \Head\direction <> #eDirection_right
              \Head\direction = #eDirection_left   
              \xWaitNextMove = #True
            EndIf
            
          Case #eCtrlMode_Mouse
            ExamineMouse()
            
        EndSelect
      EndIf
    EndWith
  Next
EndProcedure

Procedure GameOver()
; ============================================================================
; NAME: GameOver
; DESC: Ende des Spieles. Ermittelt den Sieger, zeigt die Punkte an und
;       speichert den Highscore ab.
; RET:  #True
; ============================================================================
  Protected Msg.s, ScoreMsg.s, FinalScore.i
  Protected WinColor = RGB(255, 255, 255)
  Protected CanvasWidth.i, CanvasHeight.i
  
  ; Berechne die Mitte der aktuellen Spielfeldfläche inklusive Ursprung
  CanvasWidth  = Board1\PixelSize\x + Board1\Origin\x
  CanvasHeight = Board1\PixelSize\y + Board1\Origin\y
  
  ; 1. Logik: Wer hat gewonnen? Auswertung über das Players()-Array
  If GameSetup\NoOfPlayers = 2
    If Players(1)\Score > Players(2)\Score
      Msg = "Player 1 Wins!"
      FinalScore = Players(1)\Score
    ElseIf Players(2)\Score > Players(1)\Score
      Msg = "Player 2 Wins!"
      FinalScore = Players(2)\Score
    Else
      Msg = "It's a Draw!"
      FinalScore = Players(1)\Score
    EndIf
    NumberVersus + 1
  Else
    Msg = "Game Over!"
    FinalScore = Players(1)\Score
  EndIf
  
  ScoreMsg = "Final Score: " + Str(FinalScore)
  
  ; 2. Anzeige zentriert auf dem Screen ausgeben
  If StartDrawing(ScreenOutput())
    DrawingMode(#PB_2DDrawing_Transparent)
    
    ; Hauptnachricht exakt mittig platzieren
    DrawText(CanvasWidth / 2 - TextWidth(Msg) / 2, CanvasHeight / 2 - 40, Msg, WinColor)
    DrawText(CanvasWidth / 2 - TextWidth(ScoreMsg) / 2, CanvasHeight / 2, ScoreMsg, WinColor)
    
    ; 3. Highscore-Check (Nur im Singleplayer-Modus sinnvoll)
    If GameSetup\NoOfPlayers = 1 And FinalScore > HiScore
      HiScore = FinalScore
      Protected HiMsg.s = "A NEW HIGHSCORE!"
      DrawText(CanvasWidth / 2 - TextWidth(HiMsg) / 2, CanvasHeight / 2 + 40, HiMsg, RGB(255, 215, 0))
    EndIf
    
    StopDrawing()
  EndIf
  
  FlipBuffers()
  
  ; 4. Hintergrundmusik stoppen, falls ein Soundkanal aktiv ist
  If IsSound(SoundID): StopSound(SoundID): EndIf 
  
  ; 5. Highscore und Versus-Matches mit deiner Verschlüsselung speichern
  If CreateFile(0, "HS.snake")
    WriteLong(0, HiScore - 1234567890)
    WriteLong(0, NumberVersus - 1234567890)
    CloseFile(0)
  EndIf
  
  ; Kurze Pause, damit der Spieler das Ergebnis in Ruhe lesen kann
  Delay(2000)
  
  ProcedureReturn #True
EndProcedure       

Procedure CheckGameOver(SnakeID.i)
; ============================================================================
; NAME: CheckGameOver
; DESC: Wird aufgerufen, wenn eine Schlange kollidiert. Setzt den Flag, 
;       dass das Spiel beendet werden soll.
; VAR(SnakeID): ID der gecrashten Schlange
; RET:  #True (Signalisiert der Hauptschleife das Spielende)
; ============================================================================
  
  ; Hier ermitteln wir kurz vor dem Ende, welcher Spieler verloren hat.
  ; Wenn im 2-Spieler-Modus Schlange 1 stirbt, gewinnt automatisch Spieler 2.
  If GameSetup\NoOfPlayers = 2
    If SnakeID = 1
      PlayerWin = 2
    ElseIf SnakeID = 2
      PlayerWin = 1
    EndIf
  EndIf
  
  ProcedureReturn #True
EndProcedure

 Enumeration WINDOWS 1
    #wndMenu
    #wndGame 
 EndEnumeration
  
  Enumeration GADGETS 1
    #GADGET_FullScreen        
    #GADGET_Players           
    #GADGET_Launch            
    #GADGET_Cancel            
    #GADGET_Controller         
    #GADGET_ColorSelect1      
    #GADGET_ColorSelect2      
    #GADGET_Sound             
    #GADGET_Speed            
    #GADGET_MaxFood           
   
    ; NEU: Statische IDs für die Beschriftungen, um #PB_Any Konflikte zu lösen
    #GADGET_TxtSpeed
    #GADGET_TxtMinus1
    #GADGET_TxtPlus1
    #GADGET_TxtMaxFood
    #GADGET_TxtMinus2
    #GADGET_TxtPlus2
  EndEnumeration


Procedure MenuWindow_Create()
; ============================================================================
; NAME: MenuWindow_Create
; DESC: Erstellt das Hauptmenü-Fenster mit allen Einstellungen.
;       Korrgiert: Überlappende Klickboxen der Highscores und Regler-Layouts.
; RET:  #True wenn erfolgreich, sonst #False
; ============================================================================
  
  Protected Top
    
  ; KORREKTUR: Fenster öffnet sich sofort sichtbar unter dem korrekten Handle #wndMenu
  If OpenWindow(#wndMenu, 0, 0, 300, 400, "Snakes: by Stefan Maag; Kenny Cason", #PB_Window_ScreenCentered | #PB_Window_SystemMenu | #PB_Window_Invisible)
    
    ; Highscore aus Datei laden
    If ReadFile(0, "HS.snake")
       HiScore = ReadLong(0) + 1234567890
       NumberVersus = ReadLong(0) + 1234567890
       If NumberVersus < 0 : NumberVersus = 0 : EndIf 
       If HiScore < 0 : HiScore = 0 : EndIf 
       CloseFile(0)
    EndIf 
     
    ; Hinweis: LoadAllImages() wurde aus Performance-Gründen nach ganz oben 
    ; in den Haupt-Startcode verlagert!
     
    If UseGadgetList(WindowID(#wndMenu))
      ; Erstellt Bildanzeigen für die Snake-Heads am oberen Fensterrand
      ImageGadget(#PB_Any, 0,   10, 40, 40, ImageID(#eImage_head1), #PB_Image_Border)  
      ImageGadget(#PB_Any, 32,  10, 40, 40, ImageID(#eImage_head2), #PB_Image_Border)  
      ImageGadget(#PB_Any, 64,  10, 40, 40, ImageID(#eImage_head3), #PB_Image_Border)
      ImageGadget(#PB_Any, 96,  10, 40, 40, ImageID(#eImage_head4), #PB_Image_Border)
      ImageGadget(#PB_Any, 128, 10, 40, 40, ImageID(#eImage_head5), #PB_Image_Border) 
      ImageGadget(#PB_Any, 160, 10, 40, 40, ImageID(#eImage_head6), #PB_Image_Border)
      ImageGadget(#PB_Any, 192, 10, 40, 40, ImageID(#eImage_head7), #PB_Image_Border)
      ImageGadget(#PB_Any, 224, 10, 40, 40, ImageID(#eImage_head8), #PB_Image_Border)
      ImageGadget(#PB_Any, 256, 10, 40, 40, ImageID(#eImage_head9), #PB_Image_Border)
      
      Top = 60 ; Start der Anordnung der UI-Elemente
      
      ; KORREKTUR: Höhenangabe von 120 auf 20 reduziert, um unsichtbare Überlappung zu killen!
      TextGadget(#PB_Any, 120, Top + 2,  60, 20, "Hi Score")
      TextGadget(#PB_Any, 120, Top + 18, 60, 20, Str(HiScore))
      
      TextGadget(#PB_Any, 200, Top + 2,  60, 20, "Versus Matches")
      TextGadget(#PB_Any, 200, Top + 18, 60, 20, Str(NumberVersus))
      
      ; Kontrollkästchen (Checkboxes) platziere ich links daneben
      CheckBoxGadget(#GADGET_FullScreen, 20, Top, 75, 20, "Full Screen") : Top + 22
      CheckBoxGadget(#GADGET_Players, 20, Top, 75, 20, "2 Player") : Top + 25
      
      ; Trenner Überschrift
      TextGadget(#PB_Any, 20, Top, 180, 20, "Mult. Player Settings") : Top + 18
      
      ; --- KORREKTUR SPEED-REGLER ---
      TextGadget(#PB_Any, 20, Top + 2, 90, 20, "Player Speed")
      ; Symbole 12 Pixel nach oben versetzt und eng begrenzt
      TextGadget(#PB_Any, 115, Top - 12, 10, 15, "-")
      TextGadget(#PB_Any, 185, Top - 12, 10, 15, "+")
      TrackBarGadget(#GADGET_Speed, 110, Top, 80, 20, 0, 35) : Top + 32
      SetGadgetState(#GADGET_Speed, 10) 
      
      ; --- KORREKTUR MAX-FOOD-REGLER ---
      TextGadget(#PB_Any, 20, Top + 2, 90, 20, "Max Food")
      TextGadget(#PB_Any, 115, Top - 12, 10, 15, "-")
      TextGadget(#PB_Any, 185, Top - 12, 10, 15, "+")   
      TrackBarGadget(#GADGET_MaxFood, 110, Top, 80, 20, 0, 50) : Top + 38
      SetGadgetState(#GADGET_MaxFood, 7)
      
      ; Dropdowns für Farbauswahl Spieler 1 & 2
      TextGadget(#PB_Any, 10, Top, 80, 15, "Player 1")       
      ComboBoxGadget(#GADGET_ColorSelect1, 10, Top + 15, 80, 24) 
      AddGadgetItem(#GADGET_ColorSelect1, -1, "Green")       
      AddGadgetItem(#GADGET_ColorSelect1, -1, "Yellow") 
      AddGadgetItem(#GADGET_ColorSelect1, -1, "Orange") 
      AddGadgetItem(#GADGET_ColorSelect1, -1, "Blue") 
      AddGadgetItem(#GADGET_ColorSelect1, -1, "Teal") 
      AddGadgetItem(#GADGET_ColorSelect1, -1, "Red") 
      AddGadgetItem(#GADGET_ColorSelect1, -1, "Purple")
      AddGadgetItem(#GADGET_ColorSelect1, -1, "Ghost") 
      AddGadgetItem(#GADGET_ColorSelect1, -1, "Hippy") 
      SetGadgetState(#GADGET_ColorSelect1, 0)  
      
      TextGadget(#PB_Any, 120, Top, 80, 15, "Player 2")  
      ComboBoxGadget(#GADGET_ColorSelect2, 120, Top + 15, 80, 24) : Top + 45
      AddGadgetItem(#GADGET_ColorSelect2, -1, "Green") 
      AddGadgetItem(#GADGET_ColorSelect2, -1, "Yellow") 
      AddGadgetItem(#GADGET_ColorSelect2, -1, "Orange") 
      AddGadgetItem(#GADGET_ColorSelect2, -1, "Blue") 
      AddGadgetItem(#GADGET_ColorSelect2, -1, "Teal") 
      AddGadgetItem(#GADGET_ColorSelect2, -1, "Red") 
      AddGadgetItem(#GADGET_ColorSelect2, -1, "Purple")
      AddGadgetItem(#GADGET_ColorSelect2, -1, "Ghost") 
      AddGadgetItem(#GADGET_ColorSelect2, -1, "Hippy") 
      SetGadgetState(#GADGET_ColorSelect2, 1)    
      
      ; Joystick Controller Dropdown
      TextGadget(#PB_Any, 10, Top, 80, 15, "Controller") 
      ComboBoxGadget(#GADGET_Controller, 70, Top, 80, 24) : Top + 40
      AddGadgetItem(#GADGET_Controller, -1, "Disabled") 
      AddGadgetItem(#GADGET_Controller, -1, "Player 1") 
      AddGadgetItem(#GADGET_Controller, -1, "Player 2") 
      
      If JoystickExist
        SetGadgetState(#GADGET_Controller, 1) 
      Else
        SetGadgetState(#GADGET_Controller, 0)
      EndIf 
      
      ; Hintergrundmusik Dropdown
      TextGadget(#PB_Any, 10, Top - 15, 80, 60, "Music")
      ComboBoxGadget(#GADGET_Sound, 10, Top, 100, 24) : Top + 35
      AddGadgetItem(#GADGET_Sound, -1, "None") 
      AddGadgetItem(#GADGET_Sound, -1, "Music A") 
      AddGadgetItem(#GADGET_Sound, -1, "Music B")
      AddGadgetItem(#GADGET_Sound, -1, "Music C") 
      AddGadgetItem(#GADGET_Sound, -1, "Music D")         
      SetGadgetState(#GADGET_Sound, 0)  
      
      ; Steuerungsbuttons ganz unten platzieren
      ButtonGadget(#GADGET_Launch,   10, Top, 95, 28, "Play", #PB_Button_Default) 
      ButtonGadget(#GADGET_Cancel,  120, Top, 95, 28, "Exit")                     
      
    EndIf   
     
    ProcedureReturn #True 
  EndIf   
  
EndProcedure

Procedure StartGame()
; ============================================================================
; NAME: StartGame
; DESC: Initialisiert das Spielfeld, berechnet Größen, öffnet den Screen
;       und lädt die Sprites. ENTHÄLT KEINE EVENT-SCHLEIFE MEHR!
; RET:  -
; ============================================================================
  
  Protected I, ScreenX, ScreenY, OriginX, OriginY
  
  ; 1. Daten aller Snakes zurücksetzen
  For I = 1 To ArraySize(Snakes())
    With Snakes(I)
      ClearList(\Body())
      \Credits = 0
      \Length = 3
      \Head\direction = 0
      \Head\x = 0
      \Head\y = 0
      \SpriteID_Body = #eSprite_Nothing
      \eSnakeType = #eSnakeType_invisible
      \PlayerID = 0
      \Speed = 35 - GameSetup\StartSpeed
      \TmrSpeed = \Speed ; Startwert für den Timer setzen
    EndWith
  Next
  
  ; Player-IDs zuordnen
  For I = 1 To GameSetup\NoOfPlayers
    With Players(I)
      If \SnakeID > 0 And \SnakeID <= ArraySize(Snakes())
        Snakes(\SnakeID)\PlayerID = I
      EndIf
    EndWith
  Next
  
  Snakes(1)\SpriteID_Body = GetSpriteID_body(GameSetup\SnakeType1)
  Snakes(1)\eSnakeType = GameSetup\SnakeType1
  
  If GameSetup\NoOfPlayers = 2
    Snakes(2)\SpriteID_Body = GetSpriteID_body(GameSetup\SnakeType2)
    Snakes(2)\eSnakeType = GameSetup\SnakeType2
  EndIf

  ClearList(Foods()) 
  ClearList(Wall())  
  xGameOver = #False
  
  ; 2. Screen-Größen berechnen
  Board_InitData() 
   
  If GameSetup\xFullScreen 
    ExamineDesktops()
    With Board1
      \Fields\x = ((DesktopWidth(0) - \Origin\x - 1) / \PixelPerField\x) - 1
      \Fields\y = ((DesktopHeight(0) - \Origin\y - 1) / \PixelPerField\x) - 1
    EndWith
    OriginX = 0
    OriginY = 0
  Else
    With Board1
      \Fields\x = 30
      \Fields\y = 30
    EndWith
    OriginX = 200   
    OriginY = 200   
  EndIf
  
  Board_InitData() 
  
  ScreenX = Board1\PixelSize\x + 2 + Board1\Origin\x 
  ScreenY = Board1\PixelSize\y + 2 + Board1\Origin\y 
  
  ; 3. Game Window / Screen öffnen
  If GameSetup\xFullScreen
    If OpenScreen(DesktopWidth(0), DesktopHeight(0), 32, "Snakes")
    Else
      MessageRequester("Snakes", "Unable to open FullScreen!", #PB_MessageRequester_Error)
    EndIf
  Else
    If OpenWindow(#wndGame, OriginX, OriginY, ScreenX, ScreenY, "Snakes", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget)
      OpenWindowedScreen(WindowID(#wndGame), 0, 0, ScreenX, ScreenY, #True, 0, 0, #PB_Screen_NoSynchronization)
    Else
      MessageRequester("Snakes", "Unable to open Windowed Screen!", #PB_MessageRequester_Error)
    EndIf 
  EndIf
  
  Delay(5) 
  ; Sprites müssen bei jedem Spielstart neu geladen werden, da
  ; Sprites einen activen OpenScreen benötigen.
  LoadAllSprites() ; Sprites in den Speicher laden
  
  ; 4. Start-Foods zeitversetzt generieren
  For I = 1 To GameSetup\MaxFoods
    Foods_AddRandomFood(1, I * 500) 
  Next
  
  ; 5. Globalen Start-Timer für die Logik initialisieren
  ; StartTime = ElapsedMilliseconds()
  StartTime = 0
 
  ; WICHTIG: Die Prozedur endet hier! Sie gibt die Kontrolle sofort 
  ; an den zentralen "START Programmcode" zurück.
EndProcedure

; ****************************************************************************
;-            S T A R T   P R O G R A M M C O D E 
; ****************************************************************************
;{
; Von hier aus startet das Programm

Global Event, players, exit
Global GameActive = #False

InitSprite()  
If InitSprite() = 0
  MessageRequester("Error!", "Initializing Sprite Enviroment failed!", #PB_MessageRequester_Error)  
EndIf

If InitSound()
  Sound = 1
EndIf 

InitKeyboard()      

If InitJoystick()
  GameSetup\JoyStickExist = #True
EndIf 

LoadAllImages()
LoadSnakeSounds()   
Init_FoodTemplates()

; Wir können Sprites hier nicht direkt laden, da
; Sprites zuerst einen OpenScreen Befehl benötigen.
; den gibt es erst beim Erstellen des Spielfeldes.
; wir müssen die Sprites bei jedem Spiel Start 
; neu laden!
; LoadAllSprites() ; Sprites in den Speicher laden

#MenuAction_StartGame = 1
#MenuAction_EndProgram = 2

; Fenster-Erstellung prüfen (Nutzt das korrekte #wndMenu)
If MenuWindow_Create()
  HideWindow(#wndMenu, #False)
Else
  End
EndIf

; Lokale Variablen für das Takt-Timing der Engine
Define I, killed, xDraw
Define CycleTime

exit = #False
Repeat
  
  ; 1. WENN DAS SPIEL NICHT LÄUFT: Reines Menü-Handling
  If GameActive = #False
    Event = WaitWindowEvent()
    
    Select Event
      Case #PB_Event_Gadget
        Select EventGadget()
            
          Case #GADGET_Speed
            ; AKTIVIERUNG: Liest den aktuellen Zustand live aus.
            ; Das leert die Windows-Queue und gibt die grafische Schiebe-Animation frei!
            GameSetup\StartSpeed = GetGadgetState(#GADGET_Speed)
            Debug "Speed Gadget"
            
          Case #GADGET_MaxFood
            ; AKTIVIERUNG: Liest den aktuellen Zustand live aus.
            ; Das leert die Windows-Queue und gibt die grafische Schiebe-Animation frei!
            GameSetup\MaxFoods = GetGadgetState(#GADGET_MaxFood)
           Debug "MaxFood Gadget"
            
          Case #GADGET_Sound
            SoundIDnew = GetGadgetState(#GADGET_Sound) + #eSound50 - 1
            If SoundIDnew >= #eSound50
              If SoundIDnew <> SoundIDold
                If SoundIDold >= #eSound50: StopSound(SoundIDold): EndIf 
                SoundIDold = SoundIDnew
                PlaySound(SoundIDnew, #Null)
              EndIf
            Else
              If SoundIDold >= #eSound50: StopSound(SoundIDold): EndIf 
            EndIf 
            
          Case #GADGET_Launch
            ; Werte aus dem Menü final in das Setup-Struktur mappen
            With GameSetup
              \xFullScreen = GetGadgetState(#GADGET_FullScreen)
              \StartSpeed = GetGadgetState(#GADGET_Speed)     
              players = GetGadgetState(#GADGET_Players)
              If players : \NoOfPlayers = 2 : Else : \NoOfPlayers = 1 : EndIf 
              \SnakeType1 = GetGadgetState(#GADGET_ColorSelect1) + 1  
              \SnakeType2 = GetGadgetState(#GADGET_ColorSelect2) + 1  
              playerjoystick = GetGadgetState(#GADGET_Controller) 
              \MaxFoods = GetGadgetState(#GADGET_MaxFood)
            EndWith
            
            ; Spieler 1 initialisieren
            With Players(1)
              \SnakeID = 1: \Score = 0: \eCtrlMode = #eCtrlMode_Keyboard
              \KeysIDs\Up = #PB_Key_Up: \KeysIDs\Right = #PB_Key_Right
              \KeysIDs\Down = #PB_Key_Down: \KeysIDs\Left = #PB_Key_Left
            EndWith
            
            ; Spieler 2 initialisieren
            If GameSetup\NoOfPlayers = 2
              With Players(2)
                \SnakeID = 2: \Score = 0: \eCtrlMode = #eCtrlMode_Keyboard
                \KeysIDs\Up = #PB_Key_W: \KeysIDs\Right = #PB_Key_D
                \KeysIDs\Down = #PB_Key_S: \KeysIDs\Left = #PB_Key_A
              EndWith
            EndIf
          
            HideWindow(#wndMenu, #True)  ; Menü ausblenden
            StartGame()                  ; Screen öffnen & initialisieren (Teil 17)
            GameActive = #True           ; Engine auf Spielmodus umschalten
            StartTime = ElapsedMilliseconds() 
            xDraw = #True                
            
          Case #GADGET_Cancel
            exit = #MenuAction_EndProgram
        EndSelect
        
      Case #PB_Event_CloseWindow
        exit = #True
    EndSelect
  EndIf
  
  ; 2. WENN DAS SPIEL LÄUFT: Echtzeit-Engine
  If GameActive = #True
    Event = WindowEvent() 
    
    If Event = #PB_Event_CloseWindow
      xGameOver = #True
    EndIf
    
    ; --- PAUSE LOGIK ---
    ExamineKeyboard()
    If KeyboardReleased(#PB_Key_Space)
      GameSetup\xPaused = #True
      DrawTextXY("PAUSE", (Board1\PixelSize\x + Board1\Origin\x)/2 - 50, (Board1\PixelSize\y + Board1\Origin\y)/2)
      FlipBuffers()
      
      Repeat
        Delay(10)
        ExamineKeyboard()
      Until KeyboardReleased(#PB_Key_Space) Or KeyboardReleased(#PB_Key_Escape)
      
      GameSetup\xPaused = #False
      StartTime = ElapsedMilliseconds() 
    EndIf
    
    ; --- SPIEL-TAKTTICK (10ms) ---
    If ElapsedMilliseconds() - StartTime >= #CTMR_BaseTime
      CycleTime = ElapsedMilliseconds() - #CTMR_BaseTime
      StartTime = ElapsedMilliseconds()
      
      CounterBasedTimers() 
      Keyboard() 
      
      ; Schlangen bewegen
      For I = 1 To ArraySize(Snakes())
        With Snakes(I)
          If \eSnakeType <> #eSnakeType_invisible
            \TmrSpeed - 1
            If \TmrSpeed < 1
              \TmrSpeed = \Speed
              Snake_Move(I)
              killed = Snake_DetectCollision(I)
              xDraw = #True
              
              If killed
                xGameOver = CheckGameOver(I)
              EndIf
            EndIf
          EndIf
        EndWith
      Next
      
      ; ============================================================================
      ; KORREKTUR: Diese 3 Food-Blöcke MÜSSEN zwingend HIER innerhalb des 
      ; 10ms-Timers stehen, damit Lebenszeit korrekt läuft!
      ; ============================================================================
      
      ; Food-Nachschub alle 500ms (basiert auf CTmr, der im 10ms-Takt runterzählt)
      If CTmr(#CTMR_500ms) = 0
        Foods_AddRandomFood(1)
        xDraw = #True
      EndIf  
      
      ; Food-Bewegung alle 1000ms
      If CTmr(#CTMR_1000ms) = 0
        If Foods_Move()
          xDraw = #True
        EndIf
      EndIf
      
      ; Food-Lebenszeit exakt im 10ms-Takt verringern
      If Foods_LifeTime()
        xDraw = #True
      EndIf
      
      ; ============================================================================
      
      ; Render-Pipeline triggern
      If xDraw
        Board_Draw()
        xDraw = #False 
      EndIf
      
      ; Match-Ende auswerten
      If xGameOver Or KeyboardPushed(#PB_Key_Escape)
        GameOver()
        
        CloseScreen()
        If GameSetup\xFullScreen = #False
          CloseWindow(#wndGame)
        EndIf
        
        GameActive = #False
        HideWindow(#wndMenu, #False) ; Menü zurückholen
      EndIf
    EndIf
    
    Delay(1) 
  EndIf
  
Until exit
End
  
; *******************  E N D   P R O G R A M M  ******************************
;}
  
; ============================================================================
; NAME: Data Section
; DESC: Includes the Bitmap-Sprites and the sound files into the .EXE 
; DESC: This crates bigger .EXE but no extra Files needed
; ============================================================================


DataSection  
  ; #PS$ ist ein in Purebasic vordefinierter String für das Ordnertrennzeichen "\", was
  ; bei Windows und Linux unterschiedlich ist: Win: "\" ; Linux "/"
   head1:   :IncludeBinary "sprites" + #PS$ + "head1.bmp"
   head2:   :IncludeBinary "sprites" + #PS$ + "head2.bmp"
   head3:   :IncludeBinary "sprites" + #PS$ + "head3.bmp"
   head4:   :IncludeBinary "sprites" + #PS$ + "head4.bmp"
   head5:   :IncludeBinary "sprites" + #PS$ + "head5.bmp"
   head6:   :IncludeBinary "sprites" + #PS$ + "head6.bmp"
   head7:   :IncludeBinary "sprites" + #PS$ + "head7.bmp"
   head8:   :IncludeBinary "sprites" + #PS$ + "head8.bmp"
   head9:   :IncludeBinary "sprites" + #PS$ + "head9.bmp"
   
   body1:   :IncludeBinary "sprites" + #PS$ + "body1.bmp"
   body2:   :IncludeBinary "sprites" + #PS$ + "body2.bmp"
   body3:   :IncludeBinary "sprites" + #PS$ + "body3.bmp"
   body4:   :IncludeBinary "sprites" + #PS$ + "body4.bmp"
   body5:   :IncludeBinary "sprites" + #PS$ + "body5.bmp"
   body6:   :IncludeBinary "sprites" + #PS$ + "body6.bmp"
   body7:   :IncludeBinary "sprites" + #PS$ + "body7.bmp"
   body8:   :IncludeBinary "sprites" + #PS$ + "body8.bmp"
   body9:   :IncludeBinary "sprites" + #PS$ + "body9.bmp"

   food1:   :IncludeBinary "sprites" + #PS$ + "Food_Ant.bmp"
   food2:   :IncludeBinary "sprites" + #PS$ + "Food_Apple.bmp"
   food3:   :IncludeBinary "sprites" + #PS$ + "Food_Bee.bmp"
   food4:   :IncludeBinary "sprites" + #PS$ + "Food_Bug.bmp"
   food5:   :IncludeBinary "sprites" + #PS$ + "Food_Burger.bmp"
   
   food6:   :IncludeBinary "sprites" + #PS$ + "Food_Cherry.bmp"
   food7:   :IncludeBinary "sprites" + #PS$ + "Food_Crab.bmp"
   food8:   :IncludeBinary "sprites" + #PS$ + "Food_CupCake.bmp"
   food9:   :IncludeBinary "sprites" + #PS$ + "Food_FrenchFries.bmp"
   food10:  :IncludeBinary "sprites" + #PS$ + "Food_Grape.bmp"
   
   food11:  :IncludeBinary "sprites" + #PS$ + "Food_Mouse.bmp"
   food12:  :IncludeBinary "sprites" + #PS$ + "Food_Mushroom.bmp"
   food13:  :IncludeBinary "sprites" + #PS$ + "Food_Scorpion.bmp"
   food14:  :IncludeBinary "sprites" + #PS$ + "Food_Spider.bmp"
   food15:  :IncludeBinary "sprites" + #PS$ + "Food_Turtle.bmp"

   misc1:   :IncludeBinary "sprites" + #PS$ + "mystery.bmp"  
   
   wall1:   :IncludeBinary "sprites" + #PS$ + "wall.bmp" 
   
   sound0:  :IncludeBinary "sound" + #PS$ + "item1.wav"
   sound1:  :IncludeBinary "sound" + #PS$ + "item2.wav"
   sound2:  :IncludeBinary "sound" + #PS$ + "item3.wav"   
   sound50: :IncludeBinary "sound" + #PS$ + "music_A.wav"
   sound51: :IncludeBinary "sound" + #PS$ + "music_B.wav"
   sound52: :IncludeBinary "sound" + #PS$ + "music_C.wav"
   sound53: :IncludeBinary "sound" + #PS$ + "music_D.wav"

 EndDataSection  
 

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 2585
; FirstLine = 2570
; Folding = --------
; Optimizer
; EnableXP
; Executable = Snakes_sm.exe
; CPU = 2
; Warnings = Display