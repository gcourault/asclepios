FUNCTION var2char(expAnyType)
DO CASE
CASE VALTYPE(expAnyType) == "C"
  RETURN expAnyType
CASE VALTYPE(expAnyType) == "D"
  RETURN DTOC(expAnyType)
CASE VALTYPE(expAnyType) == "N"
  RETURN ALLTRIM(STR(expAnyType))
CASE VALTYPE(expAnyType) == "L"
  RETURN IIF(expAnyType,".T.",".F.")
CASE TYPE(expAnyType) == "M"
  RETURN ''
ENDCASE
return ''

