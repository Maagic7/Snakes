; ===========================================================================
;  FILE : snakes_sm.pbi
;  NAME : Snakes 

;  DESC : Snakes Game
;  DESC : Projekt für die Programmierausbildung in Schulen
;  DESC : oder Programmierkursen. Mit Anleitung des Ausbilders
;  DESC : durchaus für Programmiereinsteiger gedacht.
;  DESC : Der Code ist extra umfangreich dokumentiert,
;  DESC : sauber in kleine verständliche Sub-Routinen unterteilt,
;  DESC : welche als einzelne Programmierübungen herausgegriffen werden
;  DESC : können. 

;  DESC : Es handelt sich um eine reine procedurale Prgogrammierung
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
;  DESC : PureBasic ist viel nährer an C als klassiche Basic Dialekte
;  DESC : und eigenet sich daher auch hervoragend als Vorbereitung
;  DESC : auf C und Java. Bei PureBasic ist viel unötiges
;  DESC : getippe, wie z.B. bei PASCAL, einfach nicht nötig.
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
;   Übung 3: Grobes duchgehen durch die einzelnen Programmsektionen
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
; VERSION  :  0.5
; COMPILER :  PureBasic 5.73  www.PureBasic.com
; ===========================================================================
; ChangeLog:  21.02-30.03.2022
;             - komplette Erneuerung des Programm Codes. Vom original
;               blieb fast nichts übrig. 
;             - Zusätzliche Foods hinzugefügt. Bewegliche Foods eingeführt.
;             - detaillierte Code Doumentation
;
;             19/20.02.2022 original Code von Kenny Cason dokumentiert
;            - Codeupdate von PureBasic 3 auf 5.73
;            - von alter Gosub Technik auf Procedur-Technik umgestellt
;            - auf expliziete Varibalendefinition umgestellt (EnableExplicit)
;              somit werden Tippfehler in Varibalen erkannt.
;            - Konstanten statt fixer Zahlen für bessere Lesbarkeit
;            - Code optimiert und Fehler behoben
; ============================================================================

;- ---------------------------------------------------------------------
;- To Do
;  ---------------------------------------------------------------------
;  GameOver Procedure

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
  
  ; Hintergundmelodien
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
; da wir teils für die Sprites 4 Richtunge benötigen, erzeugen wir die SpriteIDs
; mit einem Abstand von 4, wir beginnen mit 0. Es handelt sich erstmal nur im IDs, so dass wir 
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
  #eSprite_body7   ; purpel
  #eSprite_body8   ; ghost
  #eSprite_body9   ; hippy
    
  #eSprite_head1   ; green
  #eSprite_head2   ; yellow
  #eSprite_head3   ; orange
  #eSprite_head4   ; blue
  #eSprite_head5   ; teal (türkis)
  #eSprite_head6   ; red
  #eSprite_head7   ; purpel
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

Enumeration eElement ; IDs f+r die möglichen Element-Typen am Feld
  #eElement_Nothing = 0 ; nichts
  #eElement_TFood       ; Food-Element vom Typ THead
  #eElement_THead       ; Snake-Head   vom Typ THead
  #eElement_TBody       ; Snake-Body   vom Typ TBody
  #eElement_TWall       ; Wand-Element vom Typ TWall 
  #eElement_BoardLimit  ; Spielfeldgrenze
EndEnumeration

Structure TPoint    ; Type Point
  x.i               ; X-Kooridinate
  y.i               ; Y-Koordinate
EndStructure
    
Structure TFood ; Type Food
  x.i           ; X-Position im Speilfeld-Gitter (Pixel-Koordinaten erhält man indem man x*FieldSize\x berechnet)
  y.i           ; X-Position im Speilfeld-Gitter 
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
  eSnakeType.i      ; Typ/Farbe der Snake (Enumeration eSnakeType) 0 = #eSnakeTye_invisible
  Length.i          ; Länge des Snake in Elementen
  L_Add.i           ; Anzahl Längenelemente hinzufügen: bei jedem Move dann 1 Element verlängert bis L_Add=0
  Speed.i           ; aktuelle Geschwindigkeit des Snake
  PlayerID.i        ; ID bzw. Nr. des Spielers, der den Snake steuert
  Head.THead        ; Defintion des Snake-Head
  SpriteID_Body.i   ; Standard SpriteID der Body Elemente (wird an die Body()-Elemente vererbt)
  Credits.i         ; Summe der Credits die der Snake aufgesammelt hat
  xWaitNextMove.i   ; Hinweis für Tastaturabfrage: Mit nächster Tastaturabfrage warten bis nach nächtem Move 
  TmrSpeed.i        ; Timer, Zähler Speed 
  List Body.Tbody() ; Liste der Body-Elemente vom DatenTyp TBody
EndStructure

Structure TKeyIDs   ; Typ ControlKeys   Steuer-Tasten des Players
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

Structure TPkdFlds    ; Typ PackedFields: Hifs-Struktur um Radar-Feldbelegung in 4-Byte LONG zu packen 
  up.a                ; Feldbelegung überhalb 
  right.a             ; Feldbelegung rechts
  down.a              ; Feldbelegung unterhalb
  left.a              ; Feldbelegung links    
EndStructure

; Speicherung der Umgebung eines Feldes. Damit speichern wir die Umgebung um ein Feld
; also ausghend von einem Feld(x,y), die 4 Belegungen der 4 Nachbarn up,right,down,left
Structure TFieldRadar ; Typ FieldRadar - zur Speicherung der Umgebung eines Feldes
  StructureUnion      
    ; StructureUnion legt alle folgenden Variablendefinitionen  auf gleiche Adresse
    ; lValue und Flds sind also nur 2 verschiedene Sichten auf die gleichen Werte
    ; 1x als 4-Byte Long und 1x als 4 einzelne Bytes. Dies benztzen wir, um 
    ; die Feldbelegung rund um ein Feld als Long zu übergeben und als
    ; einzelne Felder auszuwerten.
    lValue.l          ; 4-Byte-Long
    Flds.TPkdFlds     ; Flds zerlegt lValue in 4 einzelne Bytes  
  EndStructureUnion  
EndStructure

; ----------------------------------------------------------------------
;     B O A R D   D A T A  - S P I E L F E L D  D A T E N
; ----------------------------------------------------------------------

#Board_StatusBar_Height = 32 ; Höhe der Statusbar des Spielfeldes (für Anzeigen Spielstand...)

Structure TBoard        ; Typ Board
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
  \BoardColor = RGB(0,0,0)      ; Hintergrundfarbe Boear [schwarz]
EndWith

; wird verwendet um das Element zu definieren, welches auf dem Feld plaziert ist
Structure TBoardField  ; Typ GridField für die einzelnen Felder des Spielfeldes
  ElementID.i         ; ID des auf dem Feld plazierten Elements #eElement_TFood, #eElement_THead, ...
  ptrElement.i        ; Pointer to Element Memory, Zeiger auf den Speicherplatz des Elements
EndStructure

; definiert das Spielfeld in Anzahl Feldern X und Y
Global Dim Grid.TBoardField(162,92)  ; Felder am Brett, 5K := 5120x2880 => X=160, Y=90; da 32x32 Pixel 

; ----------------------------------------------------------------------
;-  Game Settings
; ----------------------------------------------------------------------

Structure TGameSetup ; Typ für Game Einstellungen
  xFullScreen.i
  SnakeType1.i
  SnakeType2.i
  StartSpeed.i
  NoOfPlayers.i
  MaxFoods.i
  xPaused.i             ; Speiel pausieren
  JoyStickExist.i
EndStructure

Global GameSetup.TGameSetup ; Variable mit den Game-Settings

; PureBasic erstellt Arrays immer mit 0 für das erste Element, wir verwenden
; zwecks einfacherer Zuordung nur von 1..2
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
Global.i StartSpeed, MaxFood, FoodItems, Playerwin, GameOver
Global.i sound, SoundID, SoundIDnew, SoundIDold

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
; Zyklische Zählerbasierte Timer, CounterBasedTimers
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
    ; Abfrage für Timer abgelaufen If NOT CTMR(#CTMR_100ms)
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
; VAR(*): 
; RET: -
; ============================================================================
  StartDrawing(ScreenOutput())
  DrawingMode(1)
  BackColor(RGB(0,0,0))
  FrontColor(RGB(255, 255, 255))
  DrawText(x,y,text)
  StopDrawing()
EndProcedure

Macro Catch_Sprite_EX(SpriteID, DSptr, use4Dir)
; ============================================================================
; NAME: Load_Sprite_EX
; DESC: läd ein Sprite in 1er oder 4 Richtungen (up, right, down, left)
; DESC: das Sprite wird jeweils um 90° im Uhrzeigersinn gedreht
; VAR(SpriteID): SpriteID es up-Sprites
; VAR(DSptr): Data Section Pointer; Adresse im Datenbereich "?head1
; VAR(use4Dir): use 4 directions; Sprite in 4 Ausrichtunge laden
; ============================================================================
  
  CatchSprite(SpriteID,   DSptr)
  If use4Dir
    CopySprite(SpriteID, SpriteID +1)
    CopySprite(SpriteID, SpriteID +2)
    CopySprite(SpriteID, SpriteID +3)
    RotateSprite(SpriteID +1, 90, #PB_Absolute)
    RotateSprite(SpriteID +2, 180, #PB_Absolute)
    RotateSprite(SpriteID +3, 270, #PB_Absolute)
  EndIf 
EndMacro

 Procedure LoadAllSprites()
; ============================================================================
; NAME: LoadAllSprites
; DESC: Läd die Sprites aus der DataSection in den Speicher SpriteList()
; DESC: jedes Sprite braucht seine einzigartige ID (Listen-Nummer)
; DESC: Diese IDs haben wir als Konstanten bereits oben erzeugt   
; ============================================================================
  
  ; jetzt kommen die Konstanten zum Einsatz, das ist weit
  ; einfacher, als händisch hier überall korrekte Zahlen einzutragen
  ; und später dann auch die richtige Zahl wieder zu wissen!
   
  ; Macro Catch_Sprite_EX lädt Sprite in 1 (up) oder 4 Ausrichtungen (up,right,down,left) 
  ; für Sprite_Nothing laden wir ein X, damit sehen wir wenn irgenwo etwas
  ; falsch läuft, dann taucht ein X am Spielfeld auf
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
  Catch_Sprite_EX(#eSprite_body8, ?body8, #False)   ; gohst
  Catch_Sprite_EX(#eSprite_body9, ?body9, #False)   ; hippy
  
  ; FOODs : bewegliche Foods in 4 Ausrichtungen, unbwegliche in 1 Ausrichtung laden! 
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
    \LifeTime = 50000     ; Baisc LifeTime in [ms]
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
; DESC: Läd die Sounds aus der DataSection in den Speicher, SoundList()
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
; DESC: und gibt die zueghörige SnakeID zurück
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
        *THead = Grid(x, y)\ptrElement  ; den im Grid gespeichertn Pointer des Head-Elements auf Stuktur-Pointer 
        If *THead                       ; Wenn Pointer nicht 0
          ret = *THead\SnakeID          ; SankeID, des auf dem Feld befindlichen Head
        EndIf
      EndIf
    EndIf
  EndIf
  ProcedureReturn ret ; 0 or SnakeID 
EndProcedure

Procedure Field_IsEmpty(x,y)
; ============================================================================
; NAME: IsField_Empty
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
        ret = #False                      ; Rückgabewert +#True für leeres Feld
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
; VAR(*FieldRadar.TFieldRadar): Radar aus Feldischt
; RET.TFieldRadar: Radar aus Elemntsicht 
; ============================================================================
  
  Protected ER.TFieldRadar  ; Element Radar
  
  ; das Radar aus Feldsicht, also die belegten 4-Nachbarfelder up,right,down,left
  ; umschlüsseln auf das Radar aus Elementsicht, die 4 Nachbarfelder
  ; voraus, rechts, hinten, links
  ; Dies hat den Vorteil, dass man in den Bewegungsberechungen die Richtungen
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
; DESC: wobei es eine umslaufende Begrenzung ist. D.h. bei Überlauf geht
; DESC: bei 0 weiter
; RET : Xpos + delta [0..\Board\Fields\x] umlaufende Begrenzung
; ============================================================================
  Protected ret 
  
  ret = Xpos + delta
  
  ; hier die Ueberprüfung auf die Feldgrenzen. Im Gegensatz zu der
  ; TrunRight, TurnLeft Funktion, kann man hier nicht mit & Board1\Fields\x
  ; den Bereich begrenzen, da wir mit der Anzahl der Felder nicht genau
  ; einen voll ausgenutzen Bit-Bereich treffen. Wir müssen mit If
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
; DESC: wobei es eine umslaufende Begrenzung ist. D.h. bei Überlauf geht
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
  ; immer auf 0..3 begrenzen. Das könnte man If-Abfragen machen.
  ; da wir aber mit der größten Zahl 3 binär genau 2 Bits(3 = %0011) belegen,
  ; können wir durch einen binären AND Befehl (in PureBasic '&'), unseren
  ; Wert korrekt auf 2 Bits berenzen. Das funktioniert nur, wenn unser
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
; VAR(xAddElement): #False = nur Bewegung Länge bleibt
;                   #True  = Bewegung und Länge +1  
; RET: -
; ============================================================================
  

  If (SnakeID >0) And (SnakeID <= ArraySize(Snakes()))
    ; Debug "Snake Move : " + Str(SnakeID) 
        
    With Snakes(SnakeID)        ; Snakes Structure öffenen
      AddElement(\Body())       ; neues Body-Element hinzufügen
      \Body()\x = \Head\x       ; neues Body-Element bekommt Koordinaten
      \Body()\y = \Head\y       ; vom Kopf
      \Body()\pos = 1           ; Pos des Body-Elements, mit 1 Position Head starten, wird am Ende der Procedure um 1 weitergeschaltet
      \Body()\SnakeID=SnakeID   ; Referenz: Zugeörigkeit zu Snake()
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
                 
      ; hier werden alle Bodyelemente druchlaufen und jeweils um 1 in der Position 
      ; weitergeschoben. Unser neu erzeugtes Body-Element auf Pos=1 wird so gleich
      ; auf Position 2 hinter dem Kiopf geschoben. 
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
      ; in sehr viel kürzeren Zeiten (ca. 10ms) abgefragt wirdm, als die
      ; Schlange am Bildschirm bewegt wird.
      \xWaitNextMove = #False ; RESET(Wartebfehl für neue Tastaturabfrage)
     
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
; ============================================================================
; NAME: Snake_Food
; DESC: Food-Element verarbeiten
; VAR(SnakeID):  
; RET: -
; ============================================================================
  
  Protected *TFood.TFood      ; Pointer-Variable auf Food-Element
  
  If SnakeID >0 And SnakeID <= ArraySize(Snakes())
    With Snakes(SnakeID)           ; Snakes\Head Structure öffenen
      
      ; prüfen ob is sich wirklich um ein Food-Element handelt, auf welches Snake\Head bewegt wurde
      If Grid(\Head\x, \Head\y)\ElementID = #eElement_TFood
        *TFood = Grid(\Head\x, \Head\y)\ptrElement ; Pointer auf das Food-Element auf dem Grid-Daten übernehmen
        
        ; da wir mit dem Pointer *TFood direkt auf den Arbeitsspeicher zugreifen, müssen wir
        ; sicherstellen, dass der Pointer gültig (also nicht 0 ist) sonst crashed unser Programm
        ; mit einem Speicherzugriffsfehler
        If *TFood   ; Pointer<>0
          
          ; hier Aktionenen, die für alle Foods identisch sind
          Snake_AddCredits(SnakeID, *TFood\Credits) ; Credits verarbeiten; zu Snake und Player hinzufügen
          PlaySound(*TFood\SoundID, #Null)          ; Sound 1x abspielen
          
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
          
          ; jetz noch Food Aus der Foods() Liste löschen
          ResetList(Foods())            ; Foods(Liste()) auf Anfang
          While NextElement(Foods())    ; Alle Elemente der Liste druchlaufen
            If Foods()\x = *TFood\x     ; wir haben das zu löschende Food-Element
              If Foods()\y = *TFood\y   ; gefunden, wenn x- und y- Koordinate
                DeleteElement(Foods())  ; zum Food auf dem Feld passt.
                Break                   ; Food gefunden und gelöscht While Schleife verlassen
              EndIf
            EndIf
          Wend
          
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
          ; hinwegkrichen können oder nicht. Wenn wir hier
          ; killed = #False belassen, dann können wir über Snake\Bodys wandern
          ; das könnte man evtl. noch als einstellbare Option einbauen
          
          ; killed = #True ; bei #True wäre es Ende 
          
        Case #eElement_THead
          ; prüfen, ob auf dem Feld bereits ein Head eines anderen Snakes ist
          ; dann sind die beiden Snakes mit dem Kopf zusammengestossen
          ret = Field_IsSnakeHead(\x,\y)   
          If ret >0 And ret <> SnakeID ; Feld ist Kopf anderern Snakes
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
; DESC: zeichnet das Spielfeld neu
; VAR(*): 
; RET: -
; ============================================================================

  Protected I,J     ; Laufvariablen
  Protected x,y     ; Feldkoordinaten
  Protected memSprite
  
  ClearScreen(Board1\BoardColor) ; Bildschirm komplett löschen, Hintergrundfarbe schwarz
  
  ; ----------------------------------------------------------------------
  ; alle Einträge im Grid-Array erst mal löschen
  ; das erspart uns eine umständliche Löschnung einzelner Elemente,
  ; Wenn z.B. ein Food-Element verschwindet oder Snake weiter bewegt wird.
  ; Die Einträge werden beim Zeichnen der Elemente wieder neu angelegt
  ; ----------------------------------------------------------------------

  For I = 0 To Board1\Fields\x
    For J = 0 To Board1\Fields\y
      With Grid(I,J)
        \ElementID = #eElement_Nothing
        \ptrElement = 0
      EndWith
    Next
  Next
    
  ; ----------------------------------------------------------------------
  ;  alle sichtbaren Snakes 1..max zeichnen
  ; ----------------------------------------------------------------------
  For I = 1 To ArraySize(Snakes())
    
    With Snakes(I)                    ; Snake Struktur öffen
      If \eSnakeType <> #eSnakeType_invisible  ; nur wenn Snake nicht unsichtbar
        
        ; Body
        If ListSize(\Body())          ; Überprüfen, ob die Anzahl der Elemente in Body() > 0 ist
          ResetList(\Body())          ; Body Liste auf Anfang (vor erstes Element)
          While NextElement(\Body())  ; Alle Elemnte der Liste nacheinander druchlaufen
            x = \Body()\x             ; x- Position Body-Element im Grid
            y = \Body()\y             ; y- Position Body-Element im Grid
            
            ; Achtung: da x,y nur Feldkoordinaten für unser Grid-Raster sind, müssen
            ; wir die FeldPosition mit der Breite,Höhe eines Feldes multiplizieren, um Pixel zu bekommen
            If \Body()\SpriteID
              DisplayTransparentSprite(\Body()\SpriteID, x*Board1\PixelPerField\x + Board1\Origin\x, y*Board1\PixelPerField\y + Board1\Origin\y)
            Else
              DisplayTransparentSprite(#eSprite_misc1, x*Board1\PixelPerField\x+ Board1\Origin\x, y*Board1\PixelPerField\y + Board1\Origin\y)
            EndIf
        
            Grid(x,y)\ElementID = #eElement_TBody ; Feldbelegung mit Typ Body-Element im Grid eintragen
            Grid(x,y)\ptrElement =  @\Body()      ; Speicheradresse (Pointer) des Body-Elements eintragen
          Wend                                    ; @ ist in PureBasic der Befehl, die Adresse zu ermitteln
        EndIf 
        
        ; Head
        x = \Head\x   ; x- Position Head-Element im Grid
        y = \Head\y   ; y- Position Head-Element im Grid
        DisplayTransparentSprite(Snake_GetHeadSpriteID(I), x*Board1\PixelPerField\x + Board1\Origin\x, y*Board1\PixelPerField\y + Board1\Origin\y)
        Grid(x,y)\ElementID = #eElement_THead ; Feldbelegung mit Typ THead im Grid eintragen
        Grid(x,y)\ptrElement = @\Head         ; Speicheradresse (Pointer) des Head-Elements eintragen
      EndIf
    EndWith
    
  Next 
  
  ; ----------------------------------------------------------------------
  ; Foods zeichen
  ; ----------------------------------------------------------------------
  
  If ListSize(Foods())          ; Überprüfen, ob die Anzahl der Elemente in Foods() > 0 ist
    ResetList(Foods())          ; Foods Liste auf Anfang
    While NextElement(Foods())  ; Alle Elemente in Foods() nacheinander druchlaufen
      x = Foods()\x  ; x- Position Food-Element im Grid
      y = Foods()\y  ; y- Position Food-Element im Grid
      
      memSprite = Foods()\SpriteID    ; SpriteID des Foods zwischenspeichern
      If Foods()\xMovable 
        ; bei beweglichen Foods noch die Ausrichtung addieren
        ; die Sprites sind in der Richtungen nacheinander angeordnet (up,right,down,left)
        memSprite= memSprite + Foods()\direction
        ; Debug "Sprite " + Str(Foods()\SpriteID) + " - " + Str(memSprite)
      EndIf
            
      DisplayTransparentSprite(memSprite, x*Board1\PixelPerField\x + Board1\Origin\x, y*Board1\PixelPerField\y + Board1\Origin\y)
      Grid(x,y)\ElementID = #eElement_TFood  ; Feldbelegung mit Typ TFood im Grid eintragen
      Grid(x,y)\ptrElement = @Foods()        ; Speicheradresse (Pointer) des Body-Elements eintragen
      
      Foods()\LifeTime - 1
      If Foods()\LifeTime <= 0
        ; Food-Element abgelaufen, somit aus Foods() löschen. Damit wird es nächstes mal nicht mehr gezeichnet
        DeleteElement(Foods()) 
      EndIf 
    Wend
  EndIf
  
  ; ----------------------------------------------------------------------
  ; Wall Elemente (Wand-Elemente) zeichnen
  ; ----------------------------------------------------------------------
  
  If ListSize(Wall())   ; Überprüfen, ob die Anzahl der Elemente in Wall() > 0 ist
    ResetList(Wall())   ; Wall Liste Auf Anfang
    While NextElement(Wall())
      x = Wall()\x    ; x- Position Wall-Element im Grid
      y = Wall()\y    ; y- Position Wall-Element im Grid
      
      DisplayTransparentSprite(Wall()\SpriteID, x*Board1\PixelPerField\x + Board1\Origin\x, y*Board1\PixelPerField\y +Board1\Origin\y)
      Grid(x,y)\ElementID = #eElement_TWall  ; Feldbelegung mit Typ TWall im Grid eintragen
      Grid(x,y)\ptrElement = @Wall()         ; Speicheradresse (Pointer) des Wall-Elements eintragen
    Wend
  EndIf
  
  DrawTextXY("P1-Score: "  + Str(Players(1)\Score),200,0) ; Score Player 1 anzeigen
  DrawTextXY("P2-Score: "+Str(Players(2)\Score),400,0)
  ; Hi-Score anzeigen 
  DrawTextXY("Hi Score: " + Str(HiScore),0,0)
  
  ; ----------------------------------------------------------------------
  ; Grid Hilfslinien zeichnen
  ; ----------------------------------------------------------------------

  StartDrawing(ScreenOutput()) ; ScreenOutput()  WindowOutput(0)
  If Board1\xShowGrid
    For I = 0 To Board1\Fields\x +1
      Line(I*Board1\PixelPerField\x + Board1\Origin\x, Board1\Origin\y, 1, Board1\PixelSize\y, Board1\GridColor)
    Next
    
    For I = 0 To Board1\Fields\y +1
      Line(0, I*Board1\PixelPerField\y + Board1\Origin\y, Board1\PixelSize\x, 1, Board1\GridColor)
    Next
  Else
    ; nur die 4 Umrandungslinien zeichen
    ; Linie links
    Line(Board1\Origin\x, Board1\Origin\y, 1, Board1\PixelSize\y, Board1\GridColor)
    ; Linie rects
    Line(Board1\Origin\x + Board1\PixelSize\x, Board1\Origin\y, 1, Board1\PixelSize\y, Board1\GridColor)
    ; Linie oben
    Line(Board1\Origin\x, Board1\Origin\y,  Board1\PixelSize\x, 1, Board1\GridColor)
    ; Linie unten
    Line(Board1\Origin\x, Board1\Origin\y + Board1\PixelSize\y, Board1\PixelSize\x, 1, Board1\GridColor)
  EndIf
  StopDrawing()

  ; Tauscht die beiden Bildpuffer, so dass aktualisierte Grafikanzeigen angezeigt werden
  ; Die Verwendung von Vordergrund- und Hintergund- Bildpuffer sorgt für flackerfreie Anzeigen.
 FlipBuffers() 

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
;                         Angabe Optionl. Wenn 0, dann LifeTime von Template
; RET: *TFood Pointer auf das neue Food-Element
; ============================================================================
  Protected I, x, y, FoodID 
  Protected ready, ret, mem
  
  For I=1 To NoOfFoodsToAdd
  ; Food-Elemment hinzuügen, solange Max Anzahl Foods nicht erreicht
    If ListSize(Foods()) < GameSetup\MaxFoods
      
      AddElement(Foods()) ; neues Element an Liste anhängen
      
      ; Zufallszahl = 10x Anazahl FoodTypen. Dadurch kann man die Auftrittshäufigkeiten
      ; individuell einstellen. Würden wir nur 15 (=Anzahl FoodTypen) verwenden, taucht
      ; jedes Food gleich häufig auf. Wenn wir jedoch z.B. die Cherry's als special
      ; Credits verwenden möchten, sollte die weniger häufig auftreten
      mem = Random(150) ; Zufallszahl generieren
      
      ; hier kann durch einstellen der Bereiche, die Auftritthäufigkeit der einzelnen Foods eingestellt werden!
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
          \LifeTime = \LifeTime + Random(2 * mem) - mem ; Achtung Random [,Minimum] darf nicht negativ
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
        y = Random(Board1\Fields\Y)  ; Y-Position zufällig
        
        ; prüfen ob Feld bereits belegt - wenn Feld nicht leer, dann ready=#False    
        If Not Field_IsEmpty(x,y) : ready = #False : EndIf
        
        ; Mindestabstand zu Haed muss 1 freies Feld wein, deshalb die 4 Felder
        ; um das ermittelte Feld auf Head-Element pruefen
        ; aber Achtung, wir sollten nicht versuchen über unser akuelles
        ; Grid hinauszulesen, das könnte Schwierigkeiten geben,
        ; deshalb muss die neue Position auf die Grenzen GridSize\x \y
        ; geprüft werden
        
        ; Field-IsSnakeHead übernimmt bereits die Prüfung auf korrekte x,y
        ; wir müssen uns also nicht extra drum kpümmern. Wenn wir
        ; über das Grid hinuaslesen, dann wird 0 zurückgegeben, was bedeuted
        ; auf dem Feld befindet sich kein Snake\Head
        If Field_IsSnakeHead(x+1,y) : ready = #False : EndIf    
        If Field_IsSnakeHead(x-1,y) : ready = #False : EndIf
        If Field_IsSnakeHead(x,y+1) : ready = #False : EndIf
        If Field_IsSnakeHead(x,y-1) : ready = #False : EndIf
         
      Until ready ; solange wiederholen, bis Gridposition frei bzw. Abstand zu Head ok
    
      Foods()\x = x ; ermittelte und überpüfte Zufallspostion dem Food-Element
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
  Protected xMsgMoved   ; Meldung Food wurde bwegt; Rückgabewert für neu zeichenn
  Protected xCanMove = #True
  
  ; Radar Variable - für die Belegung der 4 Nachbarfelder des Food-Elements
  Protected FR.TFieldRadar ; Field Radar    - Radar aus Feldsicht
  Protected ER.TFieldRadar ; Element Radar  - Radar aus Element sicht
  
  If ListSize(Foods())            ; Wenn Foods(Liste()) nicht leer
    ResetList(Foods())            ; Foods(Liste()) auf Anfang
    While NextElement(Foods())    ; Alle Elemente der Liste druchlaufen
      
      With Foods()
        If \xMovable    ; Wenn bewegliches Food-Element
          
          ; Belegung der 4 Nachbarfelder ermitteln aus Feldsicht ermitten
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
              \direction = newDir   ; neue Bewegungsrichtung for Food übernehmen
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
                xMsgMoved = #True             ; Meldung es hat eine Bewegung stattgefundn (=>Board neu zeichnen)
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
; DESC: näschsten Zeichemvorgang nicht mehr angezeigt.  
; RET:  #True, wennn Element gelöscht (= Befehl: neu zeichenen)
; ============================================================================
 
  ; FoodLifeTime in der Speil Haupt-Schleife im BasisZeittakt von 10ms
  ; aufrufen, damit die LifeTimes korrekt stimmen
  
  Protected ret
  
  ResetList(Foods())            ; Foods(Liste()) auf Anfang
  If ListSize(Foods())
    While NextElement(Foods())    ; Alle Elemente der Liste druchlaufen
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
; DESC: 
; VAR(*): 
; RET: -
; ============================================================================
  
  Protected I, SnakeID
  Protected CtrlMode, JsID
  Protected KC.TKeyIDs  ; Bedientasten
  

  For I = 1 To GameSetup\NoOfPlayers
    With Players(I)  
      CtrlMode = \eCtrlMode
      SnakeID =\SnakeID
      KC = \KeysIDs
    EndWith
    
    With Snakes(SnakeID)   
      
      ; mit xWaitNexMove warten wir mit der Verarbeitung eines weiteren
      ; Tstendrucks, bis die letzte aktion auch gezeichnet wurde.
      ; dies ist notwendig, da die Funktionen Tastatureingaben prüfen
      ; und Board neu zeichnen zeitlich asychron zueiander laufen.
      If Snakes(snakeID)\xWaitNextMove = #False
        Select CtrlMode 
            
          Case #eCtrlMode_Keyboard
            
            ExamineKeyboard() ; aktualisieren des Tastatur Puffers
            
            If KeyboardPushed(KC\Up) And \Head\direction <> #eDirection_down
              \Head\direction = #eDirection_up   
              \xWaitNextMove = #True
            ElseIf KeyboardPushed(KC\Right) And \Head\direction <> #eDirection_left
              \Head\direction = #eDirection_right   
              \xWaitNextMove = #True
            ElseIf KeyboardPushed(KC\Down) And \Head\direction <> #eDirection_up
              \Head\direction = #eDirection_down   
              \xWaitNextMove = #True
            ElseIf KeyboardPushed(KC\left) And \Head\direction <> #eDirection_right
              \Head\direction = #eDirection_left   
              \xWaitNextMove = #True
            EndIf
            
          Case #eCtrlMode_Joystick1, #eCtrlMode_Joystick2
            ; hier die JoyStickID ermitteln Joystick1 hat ID=0, Joystick 2 ID=2
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
; NAME: Game Over
; DESC: End of the Game
; VAR(*): 
; RET: -
; ============================================================================

;   If NoOfPlayers = 2
;     If Playerwin = 1
;       DrawTextXY("Player 1 Wins!",ScreenX/2-50,ScreenY/2-15)
;       DrawTextXY("Score: "+Str(Score1),ScreenX/2-50,ScreenY/2)
;     ElseIf PlayerWin = 2
;       DrawTextXY("Player 2 Wins!",ScreenX/2-50,ScreenY/2-15)
;       DrawTextXY("Score: "+Str(Score2),ScreenX/2-50,ScreenY/2)
;     Else
;       DrawTextXY("Draw!",ScreenX/2-50,ScreenY/2-15)
;       DrawTextXY("Score: "+Str(Score1),ScreenX/2-50,ScreenY/2)
;     EndIf 
;   ElseIf NoOfPlayers = 1
;     DrawTextXY("You Lose!",ScreenX/2-50,ScreenY/2-15)
;     DrawTextXY("Score: "+Str(Score1),ScreenX/2-50,ScreenY/2)
;   EndIf
; 
;   FlipBuffers()
;   Delay(2000)
; 
;   If SoundID > 49
;     StopSound(SoundID)
;   EndIf 
;   
;   If NoOfPlayers = 1
;     If Score1 > HiScore
;       DrawTextXY("A New HighScore!",ScreenX/2-50,ScreenY/2+20)
;       FlipBuffers()
;       Delay(1400)
;       HiScore = Score1
;     EndIf 
;   EndIf 
;   
;   If NoOfPlayers = 2
;     NumberVersus + 1
;   EndIf 
;   
;   If OpenFile(0, "HS.snake")
;     WriteLong(0, HiScore-1234567890) ; a small encryption, nothing special tho
;     WriteLong(0, NumberVersus - 1234567890)
;     CloseFile(0)
;   EndIf 
       
EndProcedure

Procedure MenuWindow_Create()
; ============================================================================
; NAME: Menu
; DESC: Creates the Main Window
; VAR(*): 
; RET: -
; ============================================================================
  
  Protected Top
  
  Enumeration WINDOWS
    #wndMenu
  EndEnumeration
  
  Enumeration GADGETS
    #GADGET_FullScreen        
    #GADGET_Players           
    #GADGET_Launch            
    #GADGET_Cancel            
    #GADGET_Controller         
    #GADGET_MaxFood           
    #GADGET_ColorSelect1      
    #GADGET_ColorSelect2      
    #GADGET_Sound             
    #GADGET_Speed            
  EndEnumeration
  
  If OpenWindow(#wndMenu, 0, 0, 292, 320, "Snakes: by Stefan Maag; Kenny Cason", #PB_Window_ScreenCentered | #PB_Window_SystemMenu | #PB_Window_Invisible)
    
    If ReadFile(0, "HS.snake")
       HiScore =  ReadLong(0)+1234567890
       NumberVersus = ReadLong(0)+1234567890
       If NumberVersus < 0 
         NumberVersus = 0
       EndIf 
       If HiScore < 0 
         HiScore = 0
       EndIf 
       CloseFile(0)
     EndIf 
     
    LoadAllImages()
     
    If UseGadgetList(WindowID(#wndMenu))
      ; erstellt Bildanzeigen für die Snake-Heads am oberen Fensterrand
      ImageGadget(#PB_Any,0  ,10,40,40,ImageID(#eImage_head1),#PB_Image_Border)  
      ImageGadget(#PB_Any,32 ,10,40,40,ImageID(#eImage_head2),#PB_Image_Border)  
      ImageGadget(#PB_Any,64 ,10,40,40,ImageID(#eImage_head3),#PB_Image_Border)
      ImageGadget(#PB_Any,96 ,10,40,40,ImageID(#eImage_head4),#PB_Image_Border)
      ImageGadget(#PB_Any,128,10,40,40,ImageID(#eImage_head5),#PB_Image_Border) 
      ImageGadget(#PB_Any,160,10,40,40,ImageID(#eImage_head6),#PB_Image_Border)
      ImageGadget(#PB_Any,192,10,40,40,ImageID(#eImage_head7),#PB_Image_Border)
      ImageGadget(#PB_Any,224,10,40,40,ImageID(#eImage_head8),#PB_Image_Border)
      ImageGadget(#PB_Any,256,10,40,40,ImageID(#eImage_head9),#PB_Image_Border)
      
      Top = 50 ; Start der Anordung der Elemente bei Höhe 46 als Y-Koordinate 
      ; Beschriftungstexte
      TextGadget(#PB_Any,120,Top+2,90,20,"Hi Score")
      TextGadget(#PB_Any,120,Top+17,90,120,Str(HiScore))
      TextGadget(#PB_Any,200,Top+2,90,20,"Versus Matches")
      TextGadget(#PB_Any,200,Top+17,90,120,Str(NumberVersus))
      
      ; die bieden Check-Boxes
      CheckBoxGadget(#GADGET_FullScreen, 20, Top, 75, 20, "Full Screen") : Top + 20
      CheckBoxGadget(#GADGET_Players, 20, Top, 75, 20, "2 Player") : Top + 20
      
      TextGadget(#PB_Any,20,Top,180,20,"Mult. Player Settings") : Top + 15
      
      TextGadget(#PB_Any,20,Top+2,90,20,"Player Speed")
      TextGadget(#PB_Any,105,Top+0,10,10,"-")
      TextGadget(#PB_Any,190,Top+0,10,10,"+")
      TrackBarGadget(#GADGET_Speed, 110, Top, 80, 20, 0, 35) : Top+30
      SetGadgetState(#GADGET_Speed, 10) 
      
      TextGadget(#PB_Any,20,Top+2,90,20,"Max Food")
      TextGadget(#PB_Any,105,Top+0,10,10,"-")
      TextGadget(#PB_Any,190,Top+0,10,10,"+")   
      TrackBarGadget(#GADGET_MaxFood, 110, Top, 80, 20, 0, 50) : Top+35
      SetGadgetState(#GADGET_MaxFood, 7)
      
      ; erstellt, beschriftet und füllt Auswahlfeld für Farbe der Snake für Payer 2
      TextGadget(#PB_Any,10,Top,80,15,"Player 1")       ; erstellt Text-Feld mit Text: "Player 1"
      ComboBoxGadget(#GADGET_ColorSelect1,10,Top+15,80,24) ; erstellt das Drop-Down Auswahlfeld
      AddGadgetItem(#GADGET_ColorSelect1,-1,"Green")       ; ab hier wird das Drop-Down gefüllt
      AddGadgetItem(#GADGET_ColorSelect1,-1,"Yellow") 
      AddGadgetItem(#GADGET_ColorSelect1,-1,"Orange") 
      AddGadgetItem(#GADGET_ColorSelect1,-1,"Blue") 
      AddGadgetItem(#GADGET_ColorSelect1,-1,"Teal") 
      AddGadgetItem(#GADGET_ColorSelect1,-1,"Red") 
      AddGadgetItem(#GADGET_ColorSelect1,-1,"Purple")
      AddGadgetItem(#GADGET_ColorSelect1,-1,"Chost") 
      AddGadgetItem(#GADGET_ColorSelect1,-1,"Hippy") 
      SetGadgetState(#GADGET_ColorSelect1,0)  
      
      ; erstellt, beschriftet und füllt Auswahlfeld für Farbe der Snake für Payer 2
      TextGadget(#PB_Any,120,Top,80,15,"Player 2")  
      ComboBoxGadget(#GADGET_ColorSelect2,120,Top+15,80,24) :Top + 45
      AddGadgetItem(#GADGET_ColorSelect2,-1,"Green") 
      AddGadgetItem(#GADGET_ColorSelect2,-1,"Yellow") 
      AddGadgetItem(#GADGET_ColorSelect2,-1,"Orange") 
      AddGadgetItem(#GADGET_ColorSelect2,-1,"Blue") 
      AddGadgetItem(#GADGET_ColorSelect2,-1,"Teal") 
      AddGadgetItem(#GADGET_ColorSelect2,-1,"Red") 
      AddGadgetItem(#GADGET_ColorSelect2,-1,"Purple")
      AddGadgetItem(#GADGET_ColorSelect2,-1,"Ghost") 
      AddGadgetItem(#GADGET_ColorSelect2,-1,"Hippy") 
      SetGadgetState(#GADGET_ColorSelect2,1)    ; set (beginning with 1) the 1st item as active one
      
      ; Das Auswahlfeld für den Joystick Controller
      TextGadget(#PB_Any,10,Top,80,15,"Controller") 
      ComboBoxGadget(#GADGET_Controller,70,Top,80,24) :Top+40
      AddGadgetItem(#GADGET_Controller,-1,"Disabled") 
      AddGadgetItem(#GADGET_Controller,-1,"Player 1") 
      AddGadgetItem(#GADGET_Controller,-1,"Player 2") 
      
      If JoystickExist
        SetGadgetState(#GADGET_Controller,1) 
      Else
        SetGadgetState(#GADGET_Controller,0)
      EndIf 
      
      ; erstellt, beschriftet und füllt Drop-Down für die Auswahl der Hintergrundmusik
      TextGadget(#PB_Any,10,Top-15,80,60,"Music")
      ComboBoxGadget(#GADGET_Sound,10,Top,100,24) :Top+30
      AddGadgetItem(#GADGET_Sound,-1,"None") 
      AddGadgetItem(#GADGET_Sound,-1,"Music A") 
      AddGadgetItem(#GADGET_Sound,-1,"Music B")
      AddGadgetItem(#GADGET_Sound,-1,"Music C") 
      AddGadgetItem(#GADGET_Sound,-1,"Music D")         
      SetGadgetState(#GADGET_Sound,0)  
      
      ; hier die Tasten für "Play" und "Exit"
      ButtonGadget(#GADGET_Launch,   6, Top, 95, 28, "Play", #PB_Button_Default) ; Play
      ButtonGadget(#GADGET_Cancel, 111, Top, 95, 28, "Exit")                     ; Exit
      
    EndIf   
     
    ProcedureReturn #True ; Porcedure Rückgabewert; Window wurde erstellt; o.k.
  EndIf   ; OpenWindow    
  
EndProcedure

Procedure StartGame()
; ============================================================================
; NAME: StartGame
; DESC: 
; VAR(*): 
; RET: -
; ============================================================================
  Enumeration WINDOWS
    #wndGame
  EndEnumeration
  
  ; Höhe der Statusbar für Anzeige von Spielstand ...
  
  Protected I, Event, exit=#False
  Protected killed
  Protected ScreenX, ScreenY, OriginX, OriginY
  
  ; Daten aller Snakes löschen
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
      \Speed = 35- GameSetup\StartSpeed
      Debug "StartSpeed : " + Str (\Speed)
    EndWith
  Next
  
  ; Alle aktiven Player druchlaufen und den Snakes die ensprechende PlayerID zuordnen 
  For I = 1 To GameSetup\NoOfPlayers
    With Players(I)
      If \SnakeID > 0  And \Score <= ArraySize(Snakes())
        Snakes(\SnakeID)\PlayerID = I
       EndIf
    EndWith
  Next
  
  Snakes(1)\SpriteID_Body = GetSpriteID_body(GameSetup\SnakeType1)

  With Players(1)
     Snakes(\SnakeId)\eSnakeType = GameSetup\SnakeType1
  EndWith
  
  If GameSetup\NoOfPlayers =2
    With Players(2)
      Snakes(\SnakeId)\eSnakeType = GameSetup\SnakeType2
      Snakes(2)\SpriteID_Body = GetSpriteID_body(GameSetup\SnakeType2)
    EndWith
  EndIf

  ClearList(Foods()) ; Liste der Food-Elemnte leeren 
  ClearList(Wall())  ; Liste der Wall-Elemente leeren
  
  GameOver = #False
  
  ; ----------------------------------------------------------------------
  ;  Screen Setting
  ; ----------------------------------------------------------------------
  Board_InitData() ; Initiale Board Daten berchen  \PixelSize\x,y
   
  If GameSetup\xFullScreen 
    ; Bei FullScreen Anwendung müssen wir unbedingt erst
    ; Desktopfunktionen aktivieren, da wir kein extra Fenster öffnen
    ; und unsere FullScreen Zeichnfläche direkt über dem Desktop liegt-
    ; Bei Ausfühung in einem Fenster ist das anders!
    ExamineDesktops()
    
    ; gibt die Auflösung des Bildschirms im Debug Fenster aus
    Debug "Width : " + Str(DesktopWidth(0))
    Debug "Height : "+ Str(DesktopHeight(0))
    
    With Board1
      \Fields\x = ((DesktopWidth(0)- \Origin\x -1) / \PixelPerField\x) -1
      \Fields\y = ((DesktopHeight(0)- \Origin\y -1) / \PixelPerField\x) -1
      Debug "Board Fields"
      Debug \Fields\x
      Debug \Fields\y
    EndWith
    
    OriginX = 0
    OriginY = 0
    
  Else
     ; Spielfeldgröße = Anzahl_Felder * PixelPerFild + Statusleistee_Hoehe
     With Board1
      \Fields\x = 30
      \Fields\y = 30
    EndWith
    
    OriginX = 200   ; Fentster Ursprung relativ zur rechten oberen Ecke
    OriginY = 200   ; des Desktop

  EndIf
  
  Board_InitData() ; Initiale Board Daten nochmals nachberchnen \PixelSize\x,y
  
  ; Größe der benötigten Zeichenfläche für das Spielfeld berechnen.
  ; Board1\Origin\x \y verschiebt das Spielfeld etwas, so dass
  ; wir auf der Zeichenfläche Platz für Anzeigen bekommen
  ; unser eigene Statusleiste sozusagen! Darauf geben wir Spielstand usw. aus.
  ; Die Größe der Statusleiste müssen wir zur Zeichenfläche addieren.
  ; Alternativ könnten wir die Zeichenfläche kleiner als das Fenster machen.
  ; Und die Statusleiste dann am Fenster statt am Screen platzieren.
  ; Dann muss man aber immer korrekt die Zeichenfunktionen zwichen
  ; Screen und Fenster umschalten. Bei Fullscreen ginge das dann
  ; nicht und wir müssten uns dafür wieder extra was einfallen lassn.
  ; Es ist also einfacher die Statusleiste immer am Screen mit zu zeichnen.
  ScreenX = Board1\PixelSize\x + 2 + Board1\Origin\x ;
  ScreenY = Board1\PixelSize\y + 2 + Board1\Origin\y ; 0
  
  ; ----------------------------------------------------------------------
  ;  Open Game Window
  ; ----------------------------------------------------------------------
  
  ; Achtung: wir zeichnen nicht drekt auf dem Fenster, sonder legen
  ; einen sog. Screen darüber. Screen hat den Vorteil, dass automatisch
  ; von PureBasic ein double buffering verwendet wird. D.h. 
  ; der Blidschirm (Screen) 2x erstellt. 1x als Hinergrund-Screen
  ; (in diesen wird gezeichnet) und 1x als Vordergrund-Screen (dieser
  ; wird angezeigt). Jedes mal, wenn etwas neu gezeichnet wird und
  ; angezeigt werden soll, muss FlipBuffers() verwendet werden.
  ; Dies aktualisiert den Vordergrund-Screen. Durch das double
  ; Buffering wird zwar der doppelte Speicher benötigt, es wird
  ; jedoch flackerfrei gezeichnet. Direktes Zeichnen auf dem Window
  ; würde gehen. Dies wäre dann aber ohne double Buffering und
  ; evlt. störenden Flackereffekten. Für bewegte Spiele verwendet
  ; man generell Screens!
  If GameSetup\xFullScreen
    ; bei FullScreen müssen wir nicht erst ein Window erzeugen,
    ; um einen Screen drauf zu legen. Der Screen kann direkt über
    ; den kompletten Desktop gelegt werden.
    ; InitSprite() muss vorher erfolgreich aufgerufen worden sein, sonst functioniert Screen-Befehl nicht!
    If OpenScreen(DesktopWidth(0), DesktopHeight(0), 32, "Snakes")
    Else
      MessageRequester("Snakes","Unable To open DirectX 7.0 Or later!",#PB_MessageRequester_Error)
    EndIf

  Else
  
    If OpenWindow(#wndGame,0,0,ScreenX,ScreenY, "Snakes", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget| #PB_Window_MaximizeGadget | #PB_Window_TitleBar | #PB_Window_SizeGadget  )
      OpenWindowedScreen(WindowID(#wndGame),0,0,ScreenX,ScreenY,#True,0,0,#PB_Screen_NoSynchronization)
     ; Debug "GameWindowOpen"
    Else
      MessageRequester("Snakes","Unable To open DirectX!",#PB_MessageRequester_Error)
    EndIf 
  EndIf
  
  ; 5ms Thread Wartezeit. Das gibt auch bei langsamen Rechnern dem Betriebsystem genügend Zeit, die Fenster sauber darzustellen
  Delay (5) 
  
  LoadAllSprites()    ; alle benötigten Sprites in den Arbeitsspeicher SpriteList() laden
  
  ; ----------------------------------------------------------------------
  ;- Main Event-Loop Game
  ; ----------------------------------------------------------------------
  Protected CycleTime, StartTime, xDraw
 
  StartTime = ElapsedMilliseconds()
  
  For I=1 To GameSetup\MaxFoods
    ; erzeugt Foods jeweils LifeTime 500ms versetzt, so dass nicht bei
    ; allen Foods auf einmal die LifeTime abläuft. Wenn alle auf
    ; einmal ablaufen und neu generiert werden, ist das für das Speilgeschehen störend.
    ; Probiert es aus 
    Foods_AddRandomFood(1, I*500) ; erzeugt Foods jeweils LifeTime 500ms versetzt
    
    ; AddRamdomFood(1)  
    ; würde alle Foods mit der Standard LifeTime erzeugen, so wie sie bei
    ; InitFoodTemplates()angegeben wurde
  Next
 
  Repeat 
    ; Wir müssen hier 1x die auftretenden Fenster-Ereignisse verarbeiten.
    ; Dass wir mit den Ereignissen etwas machen ist nicht notwendig.
    ; Aber sie müssen aus der sog. EventLoop entfernt werden.
    ; Tun wir das nicht, reagiert unser Fenster nach kurzer Zeit nicht 
    ; mehr. => überlaufende EventLoop
    ; Achtung: WaitWindwEvent() geht hier nicht, da WaiWindowEvent()
    ; im Gegensatz zu WindowEvent den Thread komplett anhält bis ein Ereignis auftritt.
    ; Wir müssen aber continuierlich arbeiten.
    Event = WindowEvent() 
    
    If Event = #PB_Event_CloseWindow
        exit = #True
    EndIf
      
    If GameSetup\xPaused
    ; ----------------------------------------------------------------------
    ;  Spiel pausiert?
    ; ----------------------------------------------------------------------
      
      ; durch aktualisieren von StartTime, setzen wir unsern 10ms Timer solange
      ; neu, bis die Pause aufgehoben wird.
      StartTime = ElapsedMilliseconds() 
      ExamineKeyboard()
      If  KeyboardReleased(#PB_Key_Space) Or KeyboardReleased(#PB_Key_Escape)
        GameSetup\xPaused = #False
      EndIf
    Else
    ; ----------------------------------------------------------------------
    ;  Spiel läuft!
    ; ----------------------------------------------------------------------
      If ElapsedMilliseconds()-StartTime >= #CTMR_BaseTime  ; nur alle 10ms 1x bearbeiten
        xDraw = #False   
        CycleTime = ElapsedMilliseconds() - #CTMR_BaseTime
        StartTime = ElapsedMilliseconds()
        ; Debug "Cycle : " + Str(CycleTime)
        
        CounterBasedTimers() ; StandarTimer zählerbasiert im #CTMR_BaseTime=10ms Takt aufrufen
        
        Keyboard()      ; Tastatur und Joystick Eingaben auswerten und verarbeiten
        
        For I = 1 To ArraySize(Snakes())
          With Snakes(I)
            If \eSnakeType <> #eSnakeType_invisible
              \TmrSpeed -1
              
             ; Debug "Snake " + Str(I) + " : " + Str(\TmrSpeed)
  
              If \TmrSpeed <1
                ; Debug "Snake " + Str(I) + " : " + Str(\TmrSpeed)
                \TmrSpeed = \Speed
                Snake_Move(I)
                killed = Snake_DetectCollision(I)
                xDraw = #True
                
                ; remove Snake and Check GameOver 
              EndIf
            EndIf
          EndWith
        Next
        
        ; Aufruf nur etwa alle 500ms
        If CTmr(#CTMR_500ms) = 0    ; CTmr ist das Timer-Array 0=Timer abgelaufen
          Foods_AddRandomFood(1)    ; Food Elemente hinzufügen, bis MaxFoods erreicht
            ; Debug "CTMR_500ms : " + Str(ElapsedMilliseconds())
          xDraw = #True
        EndIf  
        
        If CTmr(#CTMR_1000ms) = 0   ; CTmr ist das Timer-Array 0=Timer abgelaufen
          If Foods_Move()           ; Foods bewegen! =#True, wenn bewegt wurde
            xDraw = #True           ; Befehl Board neu zeichnen
          EndIf
        EndIf
        
        If Foods_LifeTime()    ; Food Elemente Lebenszeit überwachen, entfernen
          xDraw =#True         ; Befehl Board neu zeichnen
        EndIf
        
        If xDraw          ; Draw nur wenn Bewegung erfolgte
          Board_Draw()    ; Spielfeld zeichen
          ; Debug "Draw TimeStamp : " + Str(ElapsedMilliseconds())
        EndIf
        
        If GameOver
          GameOver()
          exit = #True
        EndIf
        
        If KeyboardPushed(#PB_Key_Escape)
          exit = #True
        EndIf
        
        If GameSetup\xFullScreen = #False And event = #PB_Event_CloseWindow 
          exit = #True
        EndIf 
      EndIf  
    EndIf
    
    ; Pause aktivieren, falls [SPACE] gedrückt wurde
    ExamineKeyboard()
    If KeyboardReleased(#PB_Key_Space) ;pause
        DrawTextXY("PAUSE",ScreenX/2-50,ScreenY/2)
        FlipBuffers()
        GameSetup\xPaused = #True
    EndIf 
    
    ; hier geben wird die Kontrolle für 1ms an das Betriebssytem zuück
    ; unser Thread wird gestoppt. Da wir nur alles 10ms unsere
    ; Game-Loop ausführen wollen und es reicht, das alle 1ms zu
    ; prüfen. Damit wird die Prozessorlast stark vermindert!
    ; würden wir das nicht tun, würde unser Programm 100% eines
    ; Prozessor-Core einnehmen, da die Game-Loop dann immer
    ; ausgeführt würde ohne etwas zu tun.
    Delay(1)  
    
  Until exit ; Ende Game-Loop
    
  If GameSetup\xFullScreen
    CloseScreen()         ; bei FullScreen nur unsern Screen über dem Desktop schließen
  Else                    
    CloseScreen()           ; bei Ausführung im Fenster muss beides 
    CloseWindow(#wndGame)   ; gescholssen werden Screen und Fenster
  EndIf
 
EndProcedure

; 
; ****************************************************************************
;-            S T A R T   P R O G R A M M C O D E 
; ****************************************************************************
;{
; von hier aus startet das Programm

Global Event, players, exit

InitSprite()        ; Initialisiert die Sprite-Umgebung zur späteren Benutzung
  
If InitSound()      ; Initialisiert die Sound-Programmumgebung
  sound= 1
EndIf 
  
InitKeyboard()      ; Initialisiert die Programmumgebung zur späteren Benutzung der Keyboard-Befehle
  
If InitJoystick()   ; Initialisiert die Programmumgebung zur späteren Benutzung der Keyboard-Befehle
  GameSetup\JoyStickExist = #True
EndIf 

LoadSnakeSounds() ; Sounddateien in Arbeitsspeicher (Sound-Liste) laden
Init_FoodTemplates()

#MenuAction_StartGame = 1
#MenuAction_EndProgram = 2

If MenuWindow_Create()
  HideWindow(#wndMenu, #False)
Else
  End
EndIf

exit = #False
Repeat  ; Wiederholungsschleife bis Programm beendet wird
  
  Event = WaitWindowEvent()   ; wartet auf ein Window Nachrichten-Ereignis und speichert dieses in Event
  
  Select Event                ; aufschlüseln der Ereignisse
    Case #PB_Event_Gadget     ; Ereignis, das ein Gadget betrift
      
      Select EventGadget()    ; Gadget-Ereignis auflschlüsseln
          
        Case #GADGET_Sound    ; Das Sound Gadget (DropDown Feld Music = Auswahl des Sounds)
          
          SoundIDnew = GetGadgetState(#GADGET_Sound) + #eSound50 -1
          ; GadGetState gibt Nr. des gweähltern Soundeintrags zurück 0=none 1=MusicA ...
          ; da die SoundIDs in der Soundliste die IDs 50..53 haben, muss der Eintrag auf die SoundID umgerechntet werden 
          If SoundIDnew >= #eSound50
            If SoundIDnew <> SoundIDold
              If SoundIDold >= #eSound50
                StopSound(SoundIDold)
              EndIf 
              SoundIDold = SoundIDnew
              PlaySound(SoundIDnew, #Null)
            EndIf
          Else    ; Sound "none" wurde ausgewählt
            If SoundIDold >= #eSound50
              StopSound(SoundIDold)
            EndIf 
          EndIf 
          
        Case #GADGET_Launch
          With GameSetup
            \xFullScreen = GetGadgetState(#GADGET_FullScreen)
            \StartSpeed = GetGadgetState(#GADGET_Speed)     
            
            players =    GetGadgetState(#GADGET_Players)
            If players : \NoOfPlayers = 2 : Else : \NoOfPlayers = 1 : EndIf 
 
            \SnakeType1 = GetGadgetState(#GADGET_ColorSelect1) + 1  ; Returns selctecd Index 0..8 + 1 => #eSnakeType_green .. #eSnakeType_Hippy => 1..9
            \SnakeType2 = GetGadgetState(#GADGET_ColorSelect2) + 1  ;
            playerjoystick = GetGadgetState(#GADGET_Controller) 
            \MaxFoods = GetGadgetState(#GADGET_MaxFood)
          EndWith
          
          ; Spieler 1 Einstellungen übernehmen
          With Players(1)
            \SnakeID = 1
            \Score = 0
            \eCtrlMode= #eCtrlMode_Keyboard
            \KeysIDs\Up = #PB_Key_Up
            \KeysIDs\Right = #PB_Key_Right
            \KeysIDs\Down = #PB_Key_Down
            \KeysIDs\Left = #PB_Key_Left
          EndWith
          
          ; Spieler 2 Einstellungen übernehmen
          If GameSetup\NoOfPlayers=2
            With Players(2)
              \SnakeID = 2
              \Score = 0
              \eCtrlMode = #eCtrlMode_Keyboard
              \KeysIDs\Up = #PB_Key_W
              \KeysIDs\Right = #PB_Key_D
              \KeysIDs\Down = #PB_Key_S
              \KeysIDs\Left = #PB_Key_A
            EndWith
          EndIf
        
          HideWindow(#wndMenu, #True)  ; Menu Window ausblenden, verstecken
          StartGame()                  ; Neues Spiel starten     
          HideWindow(#wndMenu, #False) ; nach Spielende Menu-Window wieder anzeigen 
          
        Case #GADGET_Cancel
          exit = #MenuAction_EndProgram
          
      EndSelect
      
    Case #PB_Event_CloseWindow
      exit = #True
  EndSelect
  
Until exit
   
End
  
; *******************  E N D   P R O G R A M M  ******************************
;}
  
; ============================================================================
; NAME: Data Section
; DESC: Includes the Bitmap-Sprites and the sound files into the .EXE 
; DESC: This crates bigger .EXE but no extra Files needed
; ============================================================================

CompilerIf #PB_OS_Windows
  #OS_SEP = "\"
CompilerElse
  #OS_SEP = "/"
CompilerEndIf

 DataSection     
   head1:   :IncludeBinary "sprites" + #OS_SEP + "head1.bmp"
   head2:   :IncludeBinary "sprites" + #OS_SEP + "head2.bmp"
   head3:   :IncludeBinary "sprites" + #OS_SEP + "head3.bmp"
   head4:   :IncludeBinary "sprites" + #OS_SEP + "head4.bmp"
   head5:   :IncludeBinary "sprites" + #OS_SEP + "head5.bmp"
   head6:   :IncludeBinary "sprites" + #OS_SEP + "head6.bmp"
   head7:   :IncludeBinary "sprites" + #OS_SEP + "head7.bmp"
   head8:   :IncludeBinary "sprites" + #OS_SEP + "head8.bmp"
   head9:   :IncludeBinary "sprites" + #OS_SEP + "head9.bmp"
   
   body1:   :IncludeBinary "sprites" + #OS_SEP + "body1.bmp"
   body2:   :IncludeBinary "sprites" + #OS_SEP + "body2.bmp"
   body3:   :IncludeBinary "sprites" + #OS_SEP + "body3.bmp"
   body4:   :IncludeBinary "sprites" + #OS_SEP + "body4.bmp"
   body5:   :IncludeBinary "sprites" + #OS_SEP + "body5.bmp"
   body6:   :IncludeBinary "sprites" + #OS_SEP + "body6.bmp"
   body7:   :IncludeBinary "sprites" + #OS_SEP + "body7.bmp"
   body8:   :IncludeBinary "sprites" + #OS_SEP + "body8.bmp"
   body9:   :IncludeBinary "sprites" + #OS_SEP + "body9.bmp"

   food1:   :IncludeBinary "sprites" + #OS_SEP + "Food_Ant.bmp"
   food2:   :IncludeBinary "sprites" + #OS_SEP + "Food_Apple.bmp"
   food3:   :IncludeBinary "sprites" + #OS_SEP + "Food_Bee.bmp"
   food4:   :IncludeBinary "sprites" + #OS_SEP + "Food_Bug.bmp"
   food5:   :IncludeBinary "sprites" + #OS_SEP + "Food_Burger.bmp"
   
   food6:   :IncludeBinary "sprites" + #OS_SEP + "Food_Cherry.bmp"
   food7:   :IncludeBinary "sprites" + #OS_SEP + "Food_Crab.bmp"
   food8:   :IncludeBinary "sprites" + #OS_SEP + "Food_CupCake.bmp"
   food9:   :IncludeBinary "sprites" + #OS_SEP + "Food_FrenchFries.bmp"
   food10:  :IncludeBinary "sprites" + #OS_SEP + "Food_Grape.bmp"
   
   food11:  :IncludeBinary "sprites" + #OS_SEP + "Food_Mouse.bmp"
   food12:  :IncludeBinary "sprites" + #OS_SEP + "Food_Mushroom.bmp"
   food13:  :IncludeBinary "sprites" + #OS_SEP + "Food_Scorpion.bmp"
   food14:  :IncludeBinary "sprites" + #OS_SEP + "Food_Spider.bmp"
   food15:  :IncludeBinary "sprites" + #OS_SEP + "Food_Turtle.bmp"

   misc1:   :IncludeBinary "sprites" + #OS_SEP + "mystery.bmp"  
   
   wall1:   :IncludeBinary "sprites" + #OS_SEP + "wall.bmp" 
   
   sound0:  :IncludeBinary "sound" + #OS_SEP + "item1.wav"
   sound1:  :IncludeBinary "sound" + #OS_SEP + "item2.wav"
   sound2:  :IncludeBinary "sound" + #OS_SEP + "item3.wav"   
   sound50: :IncludeBinary "sound" + #OS_SEP + "music_A.wav"
   sound51: :IncludeBinary "sound" + #OS_SEP + "music_B.wav"
   sound52: :IncludeBinary "sound" + #OS_SEP + "music_C.wav"
   sound53: :IncludeBinary "sound" + #OS_SEP + "music_D.wav"

 EndDataSection  
 
 DisableExplicit
; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 99
; FirstLine = 39
; Folding = --+-----
; Optimizer
; EnableXP
; Executable = Snakes_sm.exe
; CPU = 2
; Warnings = Display