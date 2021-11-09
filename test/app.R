library(shinythemes)
library(shiny)
library(tidyverse)
library(ggthemes)
library(ggrepel)
library(gridExtra)

#############################

# wages dataset
wages <- read_csv("wages_norepeats.csv")
wages <- as_tibble(wages) %>%
    rename(city = City, occupation = Occupation, hourly = 'Hourly Wage', annual = 'Annual Wage')

# need to remove wage values labeled as > 208,000
wages <- wages %>%
    mutate(annual  = recode(annual,
                            ">208000" = 'NA'
    )) %>%
    mutate(annual = str_remove(annual, ",")) %>% 
    mutate(annual = as.numeric(annual))

# cost of living:col dataset
cost <- read_csv("col_citydata.csv")


# set the values which can be selected from the city and occupations inputs
cities <- sort(unique(wages$city))
occupations <- sort(unique(wages$occupation))


##############################



# Define UI ----
ui <- fluidPage(theme = shinytheme("sandstone"),
                titlePanel("Checks & Cities"),
                
                # create first tab 
                tabsetPanel(
                    # name the tab
                    tabPanel("Salary by City",
                             sidebarLayout(
                                 sidebarPanel(
                                     
                                     # add text explaining process
                                     p(strong("Want to know some general information about salaries per city?")),
                                     p("Input your city of interest below to get the mean salary in that city."),
                                     br(),
                                     
                                     # select input here for mycity and myjob to be part of this panel
                                     selectInput(inputId = "mycity",
                                                 label = "What city are you interested in?", choices = cities)),
                                 
                                 # for this panel this is the main panel output
                                 mainPanel(
                                     verbatimTextOutput(outputId = "citysalary"),
                                 )
                             )
                    ),
                    
                    
                    #name of panel 2
                    tabPanel("Salary by Occupation",
                             sidebarLayout(
                                 sidebarPanel(
                                     
                                     # add text explaining process
                                     p(strong("Want to know some general information about salaries for a specific occupation?")),
                                     p("Input your desired occupation to get the average salaries by city."),
                                     br(),
                                     
                                     selectInput(inputId = "myjob",
                                                 label = "What is your occupation?", choices = occupations)),
                                 # for this panel this is the main panel output
                                 mainPanel(
                                     plotOutput(outputId = "jobsalary", height = 700))
                             )
                    ),
                    
                    # name of panel 3
                    tabPanel("Offer Comparison",
                             sidebarLayout(
                                 sidebarPanel(
                                     
                                     # add text explaining process
                                     p(strong("Do you have two competing offers from different cities that you want to compare?")),
                                     p("Input your offers and cities below."),
                                     p("The first plot will give you your cost of living (currently apartment cost). The second will give monthly salary. The third will give your remaining amount of money. Choose the city that maximizes plot 3!"),
                                     br(),
                                     
                                     # these are the inputs for this panel 
                                     numericInput(inputId = "offer1",
                                                  label = "What is your first offer (annual salary)?", 50000, min = 1, max = 10000000),
                                     selectInput(inputId = "city1",
                                                 label = "What city is your first offer in?", choices = cities, selected = "Los Angeles"),
                                     numericInput(inputId = "offer2",
                                                  label = "What is your second offer (annual salary)?", 50000, min = 1, max = 10000000),
                                     selectInput(inputId = "city2",
                                                 label = "What city is your second offer in?", choices = cities, selected = "Boston")),
                                 # this is the main panel output for this tab
                                 mainPanel(
                                     plotOutput(outputId = "comparison", height = 700)
                                 )
                             )
                    )
                )
                
)

# Define server logic ----
server <- function(input, output) {
    
    # Return mean salary
    # use {} otherwise it will not work since you are defining something within this output
    output$citysalary <- renderText({
        mean_salary <- wages %>%
            filter(city == input$mycity) %>%
            filter(occupation == "All Occupations") %>%
            select(annual)
        paste0( "The mean salary of all jobs in ", as.character(input$mycity) ," is $",  round(as.numeric(mean_salary), 2), ".")
    })
    
    # first plot of salary by occupations
    output$jobsalary <- renderPlot({
        # create a maxwage that will be useful in the limits of x axis for ggplot later
        maxwage <-  wages %>% 
            filter(occupation == input$myjob) %>%
            select(annual) %>% 
            summarize(max2 = max(annual, na.rm = TRUE)) %>%  .$max2
            
        # create the ggplot    
        wages %>%
            filter(occupation == input$myjob) %>%
            ggplot(., aes(x = annual, y = reorder(city, - annual), label = annual)) +
            geom_col(stat = "identity", fill = "lightsteelblue3") +
            # make the title change according to input
            labs(title = paste0("Annual Salary of ", input$myjob)) +
            theme_bw() +
            theme(axis.text.y = element_text(angle = 0, vjust = 0, hjust = 0),
                  axis.title.y = element_blank(),
                  axis.ticks.y = element_blank(),
                  axis.title.x = element_blank(),
                  panel.grid.major.y = element_blank(),
                  panel.grid.minor.y = element_blank(),
                  plot.title = element_text(face = "bold"),
                  plot.title.position = "plot") +
            scale_x_continuous(expand = c(0,0), labels = scales::comma, limits = c(0, maxwage + 10000))+
            geom_text(aes(label = paste0("$",annual), x = annual + 2500), size = 4, fontface = "bold")
    }
    )
    
    
    output$comparison <- renderPlot({
        # create two tables, to ensure the offer goes in the right row with the appropriate city
        cost1 <- cost %>%
            filter(city == input$city1 ) %>%
            filter(metrics == "Apartment (1 bedroom) in City Centre") %>%
            mutate(salary = input$offer1)
        
        cost2 <- cost %>%
            filter(city == input$city2 ) %>%
            filter(metrics == "Apartment (1 bedroom) in City Centre") %>%
            mutate(salary = input$offer2)
        
        # bind the comparison cities together
        offers <- bind_rows(cost1, cost2)
        
        # cost of living plot via 1 bed apt cost
        p1 <- ggplot(offers, aes(x = city, y = price, label = price)) +
            geom_bar(stat = "identity",  fill = "lightsteelblue3") +
            labs(title = "Cost of 1 Bedroom Apartment in City",
                 x = "$") +
            geom_text(aes(label = paste0("$",round(price,2)), y = price + 50), size = 3, fontface = "bold") +
            theme_bw() +
            theme(
                axis.title.x = element_blank(),
                axis.ticks.x = element_blank(),
                panel.grid.major.x = element_blank(),
                panel.grid.minor.x = element_blank(),
                plot.title = element_text(face = "bold"),
                plot.title.position = "plot")
        
        # salary offer plot
        p2 <- offers %>% 
            mutate(month_sal = (salary/365) * 30.5) %>%
            ggplot(., aes(x = city, y = month_sal, label = month_sal)) +
            geom_bar(stat = "identity",  fill = "lightsteelblue3") +
            labs(title = "Monthly Salary Comparison") +
            geom_text(aes(label = paste0("$",round(month_sal,2)), y = month_sal + 50), size = 3, fontface = "bold") +
            theme_bw() +
            theme(
                axis.title.x = element_blank(),
                axis.ticks.x = element_blank(),
                axis.title.y = element_blank(),
                panel.grid.major.x = element_blank(),
                panel.grid.minor.x = element_blank(),
                plot.title = element_text(face = "bold"),
                plot.title.position = "plot")
        
        
        # salary offer plot
        # make salary per month -- salary divided by 356 and then by 30.5 days
        p3 <- offers %>%
            mutate(monthly_remainder = ((salary/365) * 30.5) - price) %>%
            ggplot(., aes(x = city, y = monthly_remainder, label = monthly_remainder)) +
            geom_bar(stat = "identity",  fill = "steelblue4") +
            labs(title = "Surplus Montly Income") +
            geom_text(aes(label = paste0("$",round(monthly_remainder,2)), y = monthly_remainder + 50), size = 3, fontface = "bold") +
            theme_bw() +
            theme(
                axis.title.x = element_blank(),
                axis.title.y = element_blank(),
                axis.ticks.x = element_blank(),
                panel.grid.major.x = element_blank(),
                panel.grid.minor.x = element_blank(),
                plot.title = element_text(face = "bold"),
                plot.title.position = "plot")
        # combine all three and make this the output returned (ie do not assign it like others)
        grid.arrange(p1,p2,p3, ncol = 3)
        
    }
    )
    
}

# Run the app ----
shinyApp(ui = ui, server = server)




