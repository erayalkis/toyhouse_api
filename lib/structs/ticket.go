package structs

type Ticket struct {
	Avatar string `json:"image" binding:"required"`
	Tickets int `json:"ticket_count" binding:"required"`
}