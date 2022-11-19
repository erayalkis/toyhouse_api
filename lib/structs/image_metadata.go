package structs

type ImageMetadata struct {
	TaggedCharacters []Profile `json:"tagged_characters" binding:"required"`
	Description string `json:"description" binding:"required"`
	Date string `json:"date" binding:"required"`
}