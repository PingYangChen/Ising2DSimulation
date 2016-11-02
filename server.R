library(shiny)
library(Rcpp)
library(inline)
library(RcppArmadillo)

#sourceCpp("/srv/shiny-server/ising2D/updateIsing.cpp")
sourceCpp("updateIsing.cpp")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

	# Expression that generates a histogram. The expression is
	# wrapped in a call to renderPlot to indicate that:
	#
	#	 1) It is "reactive" and therefore should be automatically
	#			re-executed when inputs change
	#	 2) Its output type is a plot

	grids <- 32
	bdgrids <- grids + 2
	y0 <- (((1:bdgrids^2) + bdgrids - 1) %% bdgrids) + 1
	z0 <- (((1:bdgrids^2) - 1) %/% bdgrids) + 1		
	
	vals <- reactiveValues(x = rbinom(bdgrids^2, 1, 0.5)*2 - 1, 
													counter = 0, 
													bdry = unique(c(1:bdgrids, (bdgrids*(bdgrids-1)):(bdgrids^2), ((1:(bdgrids-2))*bdgrids+1), (bdgrids*(2:(bdgrids-1))))),
													randBdry = 2*rbinom(bdgrids*4 - 4, 1, 0.5) - 1,
													y0 = y0, z0 = z0
												 )
												 
	updateBdry <- reactive({
		##Set parameter of side location
		tplf <- 1	 ##top-left
		tprt <- bdgrids^2 - (bdgrids - 1)	 ##top-right
		btrt <- bdgrids^2	 ##bottom-right
		btlf <- bdgrids	 ##bottom-left
		lf <- 2:(bdgrids - 1)	 ##left
		tp <- (1:(bdgrids - 2))*bdgrids + 1	 ##top
		rt <- (bdgrids^2-(bdgrids - 2)):(bdgrids^2-1)	 ##right
		bt <- bdgrids*(2:(bdgrids - 1))	 ##bottom
		##circ <- c(tplf, tp, tprt, rt, btrt, abs(sort(-bt)), btlf, abs(sort(-lf)))
		switch(input$bdry.cond,
						whole =	 ## Change whole boundary, ...: 1 or -1
						{vals$x[vals$bdry] <- 1
						},
						each =	## Change conditions for each side, ...: factor of grids
						{vals$x[vals$bdry] <- rep(c(1, -1), each = 1)
						},
						uplo =	## Change condition for upper side and lower side
						{# Upper side
						 vals$x[c(tplf, tprt, tp, lf[which(lf < median(lf))], rt[which(rt < median(rt))])] <- 1
						 # Lower side
						 vals$x[c(btrt, btlf, bt, lf[which(lf >= median(lf))], rt[which(rt >= median(rt))])] <- -1
						},
						leri =	## Change condition for left side and right side
						{# Left side
						 vals$x[c(tplf, btlf, lf, tp[which(tp < median(tp))],bt[which(bt < median(bt))])] <- 1
						 # Right side
						 vals$x[c(tprt, btrt, rt, tp[which(tp >= median(tp))],bt[which(bt >= median(bt))])] <- -1
						},
						tri =	 ## 
						{upptri <- c(tplf, tp, tprt, rt, btrt)
						 lowtri <- c(bt, btlf, lf)
						 vals$x[upptri] <- 1
						 vals$x[lowtri] <- -1
						},
						corner =	 ## Change four corner
						{# Top-Left
						 vals$x[c(tplf, lf[which(lf < median(lf))],tp[which(tp < median(tp))])] <- 1
						 # Top-Right
						 vals$x[c(tprt, rt[which(rt < median(rt))],tp[which(tp >= median(tp))])] <- -1
						 # Bottom-Right
						 vals$x[c(btrt, rt[which(rt >= median(rt))],bt[which(bt >= median(bt))])] <- 1
						 # Bottom-Left
						 vals$x[c(btlf, lf[which(lf >= median(lf))],bt[which(bt < median(bt))])] <- -1
						},
						random = ## Random bdry
						{vals$x[vals$bdry] <- vals$randBdry
						}
					)
	})
	# Do the actual computation here.
  observe({
    isolate({
      # This is where we do the expensive computing
			updateBdry()
			msimNum <- ifelse(input$msim == "GS", 1, 2)
			vals$x <- updateIsing(vals$x, input$temp, msimNum, bdgrids)
			vals$nsim <- vals$nsim + grids*grids
      # Increment the counter
      vals$counter <- vals$counter + 1
    })
    
    # If we're not done yet, then schedule this block to execute again ASAP.
    # Note that we can be interrupted by other reactive updates to, for
    # instance, update a text output.
    if (input$GO == 1 & vals$counter <= 8e3) {
      invalidateLater(0, session)
    }
  })
	
	observeEvent(input$reset, {
		isolate({
			vals$x <- rbinom((grids + 2)^2, 1, 0.5)*2 - 1
			vals$randBdry <- 2*rbinom(bdgrids*4 - 4, 1, 0.5) - 1
			vals$counter <- 0
		})
	})
	
	output$isingPlot <- renderPlot({
		
		par(mar = c(1, 1, 3, 1))  		
		plot(0:bdgrids, 0:bdgrids, type = "n", axes = FALSE, xlab = "",ylab = "")
		if (sum(vals$x) > 0) {
			tmp <- setdiff(which(vals$x == -1), vals$bdry)
			rect(1.5, 1.5, bdgrids - .5, bdgrids - .5, col = "orangered1", border = "orangered1")
			rect(vals$y0[vals$bdry] - .5, vals$z0[vals$bdry] - .5, vals$y0[vals$bdry] + .5, vals$z0[vals$bdry] + .5, 
				col = adjustcolor(c("black", "orangered1"), alpha.f = .2)[(vals$x[vals$bdry] + 1)/2 + 1], 
				border = adjustcolor(c("black", "orangered1"), alpha.f = .2)[(vals$x[vals$bdry] + 1)/2 + 1])
			rect(vals$y0[tmp] - .5, vals$z0[tmp] - .5, vals$y0[tmp] + .5, vals$z0[tmp] + .5, col = "black", border = "black")
		} else {
			tmp <- setdiff(which(vals$x == 1), vals$bdry)
			rect(1.5, 1.5, bdgrids - .5, bdgrids - .5, col = "black", border = "black")
			rect(vals$y0[vals$bdry] - .5, vals$z0[vals$bdry] - .5, vals$y0[vals$bdry] + .5, vals$z0[vals$bdry] + .5, 
				col = adjustcolor(c("black", "orangered1"), alpha.f = .2)[(vals$x[vals$bdry] + 1)/2 + 1], 
				border = adjustcolor(c("black", "orangered1"), alpha.f = .2)[(vals$x[vals$bdry] + 1)/2 + 1])
			rect(vals$y0[tmp] - .5, vals$z0[tmp] - .5, vals$y0[tmp] + .5, vals$z0[tmp] + .5, col = "orangered1", border = "orangered1")
		}
		title(paste("Iteration = ", grids^2, " x ", vals$counter, sep = ""), line = .8)
		
	})

	

})