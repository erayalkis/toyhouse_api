package structs

type OwnershipLog struct {
	Date string `json:"date" binding:"required"`
	Description string `json:"description" binding:"required"`
	TaggedUser Profile `json:"user_link" binding:"required"`
}