library(shiny)

# Define UI for application that plots random distributions 
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Simulate 2D Ising Model"),
  
  # Sidebar with a slider input for number of observations
	fluidRow(
		column(4, 
			radioButtons("GO", "Control", c("Go" = 1, "Pause" = 0), 0, TRUE),		
			actionButton("reset", "Reset"),
			tags$hr(),
			sliderInput("temp",
										"Temperature",
										min = 0.01,
										max = 5.00,
										value = 1.5),
			selectInput("bdry.cond", "Boundary Condition", 
										c("Random Boundary" = "random",
											"All Positive" = "whole",
											"Alternative Arrange" = "each",
											"Positive Bottom" = "leri",
											"Positive Left Side" = "uplo",
											"Triangle" = "tri",
											"Corners" = "corner"),
										"random", FALSE),
			selectInput("msim", "MCMC Method", 
										c("Gibbs Sampling" = "GS",
											"Metroplis-Hasting" = "MH"),
										"GS", FALSE)			
		),							
		# Show a plot of the generated distribution
		column(8, 
			plotOutput("isingPlot", height = 400, width = 400)
		)
	)
))
