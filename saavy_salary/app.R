library(shinythemes)
library(shiny)
library(tidyverse)
library(ggthemes)
library(ggrepel)
library(grid)

#############################

# wages dataset
wages <- read_csv("/Users/danielherrera/Documents/wages_260.csv")
wages <- as_tibble(wages) %>%
    rename(city = City, occupation = Occupation, hourly = 'Hourly Wage', annual = 'Annual Wage')

# need to remove wage values labeled as > 208,000
wages <- wages %>%
    mutate(annual  = recode(annual,
                            ">208000" = 'NA'
    )) %>%
    mutate(annual = as.numeric(annual))

# cost of living:col dataset
cost <- read_csv("/Users/danielherrera/Documents/cost_living.csv")




cities <- sort(unique(wages$city))
occupations <- c("Accountants and Auditors", "Actuaries", "Aerospace Engineers", "Architecture and Engineering Occupations", "Bartenders",
                 "Biochemists and Biophysicists", "Bioengineers and Biomedical Engineers", "Chemists", "Chief Executives", "Childcare Workers",
                 "Chiropractors", "Data Scientists and Mathematical Science Occupations, All Other", "Financial and Investment Analysts, Financial Risk Specialists, and Financial Specialists, All Other",
                 "Market Research Analysts and Marketing Specialists", "Mathematicians", "Statisticians", "Software Developers and Software Quality Assurance Analysts and Testers")


##############################



# Define UI ----
ui <- fluidPage(theme = shinytheme("sandstone"),
                titlePanel("Checks & Cities"),
                sidebarLayout(
                    sidebarPanel(
                        # select input here for mycity: city you are looking at
                        selectInput(inputId = "mycity",
                                    label = "What cities are you interested in?", choices = cities),
                        selectInput(inputId = "myjob",
                                    label = "What is your occupation?", choices = occupations),
                        numericInput(inputId = "offer1",
                                     label = "What is your first offer (annual salary)?", 50000, min = 1, max = 10000000),
                        selectInput(inputId = "city1",
                                    label = "What city is your first offer in?", choices = cities, selected = "Los Angeles"),
                        numericInput(inputId = "offer2",
                                     label = "What is your second offer (annual salary)?", 50000, min = 1, max = 10000000),
                        selectInput(inputId = "city2",
                                    label = "What city is your second offer in?", choices = cities, selected = "Boston")
                    ),
                    mainPanel(
                        verbatimTextOutput(outputId = "citysalary"),
                        plotOutput(outputId = "jobsalary", height = 600),
                        plotOutput(outputId = "comparison", height = 500)
                    ))
)

# Define server logic ----
server <- function(input, output) {
    
    # Return mean salary
    output$citysalary <- renderText({
        mean_salary <- wages %>%
            filter(city == input$mycity) %>%
            filter(occupation == "All Occupations") %>%
            select(annual)
        paste0( "The mean salary in ", as.character(input$mycity) ," is $",  round(as.numeric(mean_salary), 2))
    })
    
    output$jobsalary <- renderPlot(
        wages %>%
            filter(occupation == input$myjob) %>%
            ggplot(., aes(x = annual, y = reorder(city, - annual), label = annual)) +
            geom_col(stat = "identity", fill = "lightsteelblue3") +
            labs(title = "Annual Salary") +
            theme_bw() +
            theme(axis.text.y = element_text(angle = 0, vjust = 0, hjust = 0),
                  axis.title.y = element_blank(),
                  axis.ticks.y = element_blank(),
                  axis.title.x = element_blank(),
                  panel.grid.major.y = element_blank(),
                  panel.grid.minor.y = element_blank(),
                  plot.title = element_text(face = "bold"),
                  plot.title.position = "plot") +
            scale_x_continuous(expand = c(0,0), labels = scales::comma)+
            geom_text(aes(label = paste0("$",annual), x = annual + 5000), size = 2.8, fontface = "bold")
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
        p1 <- ggplot(offers, aes(x = city, y = price)) +
            geom_bar(stat = "identity",  fill = "lightsteelblue3") +
            labs(title = "Cost of 1 Bedroom Apartment in City",
                 x = "$") +
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
            ggplot(., aes(x = city, y = month_sal)) +
            geom_bar(stat = "identity",  fill = "lightsteelblue3") +
            labs(title = "Monthly Salary Comparison") +
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
            ggplot(., aes(x = city, y = monthly_remainder )) +
            geom_bar(stat = "identity",  fill = "steelblue4") +
            labs(title = "Best Offer to Cost of Living Ratio") +
            theme_bw() +
            theme(
                axis.title.x = element_blank(),
                axis.title.y = element_blank(),
                axis.ticks.x = element_blank(),
                panel.grid.major.x = element_blank(),
                panel.grid.minor.x = element_blank(),
                plot.title = element_text(face = "bold"),
                plot.title.position = "plot")
        
        grid.arrange(p1,p2,p3, ncol = 3)
        
        
    }
    )
    
}

# Run the app ----
shinyApp(ui = ui, server = server)


