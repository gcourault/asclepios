FUNCTION varlen(expAny)
DO CASE
CASE VALTYPE(expAny) == "C"
  RETURN len(expAny)
CASE VALTYPE(expAny) == "D"
  RETURN 8
CASE VALTYPE(expAny) == "N"
  return len(alltrim(str(expAny)))
CASE VALTYPE(expAny) == "L"
  return 3
ENDCASE
return 0

