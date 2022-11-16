package structs

type Profile struct {
	Name string `json:"name" binding:"required"`
	Link string `json:"profile" binding:"required"`
}