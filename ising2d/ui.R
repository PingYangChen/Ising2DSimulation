library(shiny)

# Define UI for application that plots random distributions 
shinyUI(fluidPage(shinyjs::useShinyjs(), 
  
  # Application title
  titlePanel(tags$h1(tags$b("Simulate 2D Ising Model"))),
  
  # Sidebar with a slider input for number of observations
	fluidRow(
		column(4, 
			radioButtons("GO", tags$h3("Control"), c("Go" = 1, "Pause" = 0), 0, TRUE),		
			actionButton("reset", "Reset"),
			tags$hr(),
			sliderInput("temp",
			            tags$h3("Temperature"),
										min = 0.01,
										max = 5.00,
										value = 1.5),
			selectInput("bdry.cond", tags$h3("Boundary Condition"), 
										c("Random Boundary" = "random",
											"All Positive" = "whole",
											"Alternative Arrange" = "each",
											"Positive Bottom" = "leri",
											"Positive Left Side" = "uplo",
											"Triangle" = "tri",
											"Corners" = "corner"),
										"random", FALSE),
			selectInput("msim", tags$h3("MCMC Method"), 
										c("Gibbs Sampling" = "GS",
											"Metroplis-Hasting" = "MH"),
										"GS", FALSE)			
		),							
		# Show a plot of the generated distribution
		column(8, 
			imageOutput("isingPlot", height = 600, width = 600)
		)
	)
))
