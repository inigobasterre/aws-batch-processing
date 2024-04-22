variable "tags" {
  type = map(string)
  default = {
    _project = "inigo-basterretxea-batch-processing"
    _purpose = "testing"
    _business_criticality = "low"
    _end_date = "150624"
    _owner_email = "inigo.basterretxea@mesh-ai.com"
  }
}