#include-once
#include <SQLite.au3>
#include <SQLite.dll.au3>
#include <Timers.au3>
#include "CSV.au3"

Local $sIn, $sOut
Local $hQuery, $aRow, $sMsg
Local $aResult, $iRows, $iColumns, $iRval

_CSV_Initialise()
$csv_handle = _CSV_Open("SIT - Item.csv")
$csv_result = _CSV_GetTable2d($csv_handle, "select * from csv where `Assigned to` = 'DELI_SIT_S0003';")
;_CSV_Display2DResult($csv_result)
_CSV_SaveAs($csv_handle, "fred.csv")
_CSV_Cleanup()
Exit


;_SQLite_GetTable2d($conn, "SELECT * FROM t1;", $aResult, $iRows, $iColumns)
;_ArrayDisplay($aResult)
;Exit


;$tt = "Must always be worn properly, and ""adjusted"" tightly.Are only needed on long trips."
;$tt = StringReplace($tt, '"', '""')
;$tt = StringRegExpReplace($tt, "(?U)([\x1E\x1F])([^\x1E\x1F]*[,""][^\x1E\x1F]*)([\x1E\x1F])", '${1}"${2}"${3}')
;$tt = StringReplace($tt, "", @CRLF)
;$tt = StringReplace($tt, "", ",")
;ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $tt = ' & $tt & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
;Exit




;Local $csv_input_filename = "discipline.csv"
Local $csv_input_filename = "SIT - Item.csv"
Local $csv_output_filename = "out.csv"

Local $hStarttime = _Timer_Init()

;_SQLite_Startup ()
;_SQLite_Startup("sqlite3.dll", False, 1)
;ConsoleWrite("_SQLite_LibVersion=" &_SQLite_LibVersion() & @CRLF)
;$conn = _SQLite_Open () ; open :memory: Database
FileDelete("test.db")
;$conn = _SQLite_Open ("test.db") ; open :memory: Database
;_SQLite_EnableExtensions($conn, 1)

;_SQLite_Exec (-1, "SELECT load_extension('csv5.so');") ; CREATE a Table
;_SQLite_Exec (-1, "CREATE VIRTUAL TABLE t1 USING csv(filename='D:\dwn\example\" & $csv_input_filename & "',header=true);") ; CREATE a Table

_SQLite_SQLiteExe("test.db", ".mode csv" & @CRLF & ".import 'SIT - Item.csv' t1", $sOut, -1, True)

;ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : _Timer_Diff($hStarttime) = ' & _Timer_Diff($hStarttime) & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console

;_SQLite_GetTable2d(-1, "SELECT * FROM t1;", $aResult, $iRows, $iColumns)

;_Timer_Diff($hStarttime)

;_ArrayDisplay($aResult)

;_SQLite_Close()
;_SQLite_Shutdown()


FileDelete("out2.csv")
;_SQLite_SQLiteExe("test.db", ".headers on" & @CRLF & ".mode csv" & @CRLF & ".output out2.csv" & @CRLF & "SELECT * FROM t1;", $sOut, -1, True)
_SQLite_SQLiteExe("test.db", ".load csv5.so" & @CRLF & ".headers on" & @CRLF & ".mode ascii" & @CRLF & ".output out2.csv" & @CRLF & "SELECT * FROM t1;", $sOut, -1, True)
;ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : @error = ' & @error & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
;ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $sOut = ' & $sOut & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console

Local $csv_str = FileRead("out2.csv")

; Each of the embedded double-quote characters must be represented by a pair of double-quote characters.
$csv_str = StringReplace($csv_str, '"', '""')

; Fields with embedded commas or double-quote characters must be quoted.
$csv_str = StringRegExpReplace($csv_str, "(?U)([\x1E\x1F])([^\x1E\x1F]*[,""][^\x1E\x1F]*)([\x1E\x1F])", '${1}"${2}"${3}')

; In CSV implementations that do trim leading or trailing spaces, fields with such spaces as meaningful data must be quoted.
$csv_str = StringRegExpReplace($csv_str, "(?U)([\x1E\x1F])([^\x1E\x1F]* )([\x1E\x1F])", '${1}"${2}"${3}')
$csv_str = StringRegExpReplace($csv_str, "(?U)([\x1E\x1F])( [^\x1E\x1F]*)([\x1E\x1F])", '${1}"${2}"${3}')
$csv_str = StringRegExpReplace($csv_str, "(?U)([\x1E\x1F])( [^\x1E\x1F]* )([\x1E\x1F])", '${1}"${2}"${3}')

; Convert ascii field and record separators to csv
$csv_str = StringReplace($csv_str, "", @CRLF)
$csv_str = StringReplace($csv_str, "", ",")

FileDelete("out2.csv")
FileWrite("out2.csv", $csv_str)



Exit

Local $hStarttime = _Timer_Init()



;FileDelete($csv_output_filename)
;_WriteCSV($csv_output_filename, $aResult, ",", '"', 4)

;ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : _Timer_Diff($hStarttime) = ' & _Timer_Diff($hStarttime) & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console


_SQLite_Close()
_SQLite_Shutdown()

;~ Output:
;~
;~ Hello World



; #FUNCTION# ====================================================================================================================
; Name...........: _SQLite_EnableExtensions
; Description ...: Enables or disables loading of SQLite extensions
; Syntax.........: _SQLite_EnableExtensions($hConn, $Enable = 1)
; Parameters ....: $hConn		handle of connection
;                  $Enable		1 to enable (default) or 0 to disable
; Return values .: none
;                  @error Value(s):       -1 - SQLite Reported an Error (Check @extended Value)
;                  1 - Call prevented by safe mode (invalid handle)
;                  2 - Error calling SQLite API 'sqlite3_enable_load_extension'
;                  @extended Value(s): Can be compared against $SQLITE_* Constants
; Author ........: jchd
; ===============================================================================================================================

Func _SQLite_EnableExtensions($hConn, $Enable = 1)
    If __SQLite_hChk($hConn, 1) Then Return SetError(@error, 0, $SQLITE_MISUSE)
	Local $RetVal = DllCall($__g_hDll_SQLite, "int:cdecl", "sqlite3_enable_load_extension", "ptr", $hConn, "int", $Enable)
	If @error Then
		Return(SetError(2, 0, 0))
	Else
		If $RetVal[0] <> $SQLITE_OK Then Return(SetError(-1, $RetVal[0], 0))
	EndIf
EndFunc   ;==>__SQLite_EnableExtensions

; #FUNCTION# ====================================================================================================================
; Name...........: _WriteCSV
; Description ...: Writes a CSV-file
; Syntax.........: _WriteCSV($sFile, Const ByRef $aData, $sDelimiter, $sQuote, $iFormat=0)
; Parameters ....: $sFile      - Destination file
;                  $aData      - [Const ByRef] 0-based 2D-Array with data
;                  $sDelimiter - [optional] Fieldseparator (default: ,)
;                  $sQuote     - [optional] Quote character (default: ")
;                  $iFormat    - [optional] character encoding of file (default: 0)
;                  |0 or 1 - ASCII writing
;                  |2      - Unicode UTF16 Little Endian writing (with BOM)
;                  |3      - Unicode UTF16 Big Endian writing (with BOM)
;                  |4      - Unicode UTF8 writing (with BOM)
;                  |5      - Unicode UTF8 writing (without BOM)
; Return values .: Success - True
;                  Failure - 0, sets @error to:
;                  |1 - No valid 2D-Array
;                  |2 - Could not open file
; Author ........: ProgAndy
; Modified.......: SeanGriffin (to only quote when necessary and not add an extra @CRLF to the end of file)
; Remarks .......:
; Related .......: _ParseCSV
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WriteCSV($sFile, Const ByRef $aData, $sDelimiter=',', $sQuote='"', $iFormat=0)
	Local Static $aEncoding[6] = [2, 2, 34, 66, 130, 258]
	If $sDelimiter = "" Or IsKeyword($sDelimiter) Then $sDelimiter = ','
	If $sQuote = "" Or IsKeyword($sQuote) Then $sQuote = '"'
	Local $iBound = UBound($aData, 1), $iSubBound = UBound($aData, 2)
	If Not $iSubBound Then Return SetError(2,0,0)
	Local $hFile = FileOpen($sFile, $aEncoding[$iFormat])
	If @error Then Return SetError(2,@error,0)
	For $i = 0 To $iBound-1
		; Sean G - below
		if $i > 0 Then FileWrite($hFile, @CRLF)
		For $j = 0 To $iSubBound-1
			; Sean G - below
			Local $outer_quote = ""
			if StringInStr($aData[$i][$j], '"') > 0 or StringInStr($aData[$i][$j], ',') > 0 Then $outer_quote = '"'
			FileWrite($hFile, $outer_quote & StringReplace($aData[$i][$j], $sQuote, $sQuote&$sQuote, 0, 1) & $outer_quote)
			If $j < $iSubBound-1 Then FileWrite($hFile, $sDelimiter)
		Next
	Next
	FileClose($hFile)
	Return True
EndFunc

