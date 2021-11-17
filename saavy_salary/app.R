library(shinythemes)
library(shiny)
library(tidyverse)
library(ggthemes)
library(ggrepel)
library(gridExtra)

#############################

# wages/salary dataset
wages <- read_csv("cleaned_occupations.csv")

wages <- as_tibble(wages) %>%
    rename(city = City, occupation = Occupation, hourly = 'Hourly Wage', annual = 'Annual Wage')

# data cleaning
# need to remove wage values labeled as > 208,000
wages <- wages %>%
    mutate(annual  = recode(annual,
                            ">208000" = 'NA'
    )) %>%
    mutate(annual = str_remove(annual, ",")) %>% 
    mutate(annual = as.numeric(annual))

# cost of living data
cost <- read_csv("full_col_data.csv")

# will need to make the data wide
# create new variable which will be used to calculate monthly expenses and discretionary income
cost <- cost %>% 
    pivot_wider(names_from = metrics, values_from = price) %>% 
    # average meals per week out is 4 (16 monthly)! 
    mutate(expenses = 16 * as.numeric(`Meal, Inexpensive Restaurant`) + as.numeric(`Apartment (1 bedroom) in City Centre`) + 
               as.numeric(`Basic (Electricity, Heating, Cooling, Water, Garbage) for 915 sq ft Apartment`) + 
               as.numeric(`Internet (60 Mbps or More, Unlimited Data, Cable/ADSL)`))

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
                                     p("Input your city of interest below to get the mean salary in that city for all occupations."),
                                     br(),
                                     
                                     # select input here for mycity and myjob to be part of this panel
                                     selectInput(inputId = "mycity",
                                                 label = "What city are you interested in?", choices = cities, selected = "Boston")),
                                 
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
                                     p("Input your desired occupation to get the average salaries by city for that occupation."),
                                     br(),
                                     
                                     selectInput(inputId = "myjob",
                                                 label = "What is your occupation?", choices = occupations, selected = "Data Scientists and Mathematical Science Occupations, All Other")),
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
                                     p("The first plot will give you your cost of living. The second will give you your monthly salary. The third will give you your remaining amount of money."),
                                     p(em("Cost of living was determined by adding city averages for basic utilities, internet, one bedroom apartment in city, and 16 meals out per month.")),
                                     p(strong("Choose the city/offer that maximizes Monthly Remaining Income (plot 3)!")),
                                     br(),
                                     
                                     # these are the inputs for this panel 
                                     numericInput(inputId = "offer1",
                                                  label = "What is your first offer (annual salary)?", 60000, min = 1, max = 10000000),
                                     selectInput(inputId = "city1",
                                                 label = "What city is your first offer in?", choices = cities, selected = "Los Angeles"),
                                     numericInput(inputId = "offer2",
                                                  label = "What is your second offer (annual salary)?", 65000, min = 1, max = 10000000),
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
        paste0( "The mean salary of all jobs in ", as.character(input$mycity) ," is $",  prettyNum(round(as.numeric(mean_salary), 2), big.mark = ","), ".")
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
            ggplot(., aes(x = annual, y = reorder(city, - annual), label = prettyNum(annual, big.mark = ","))) +
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
            geom_text(aes(label = paste0("$",prettyNum(annual, big.mark = ",")), x = annual + 2500), size = 4, fontface = "bold")
    }
    )
    
    
    output$comparison <- renderPlot({
        # create two tables, to ensure the offer goes in the right row with the appropriate city
        cost1 <- cost %>%
            filter(city == input$city1 ) %>%
            select(city, expenses) %>%
            mutate(salary = input$offer1)
        
        cost2 <- cost %>%
            filter(city == input$city2 ) %>%
            select(city, expenses) %>%
            mutate(salary = input$offer2)
        
        # bind the comparison cities together
        offers <- bind_rows(cost1, cost2)
        
        # cost of living plot via 1 bed apt cost
        p1 <- ggplot(offers, aes(x = city, y = expenses, label = expenses)) +
            geom_bar(stat = "identity",  fill = "lightsteelblue3") +
            labs(title = "Monthly Expenses",
                 x = "$") +
            geom_text(aes(label = paste0("$",prettyNum(round(expenses,2), big.mark = ",")), y = expenses + 50), size = 4, fontface = "bold") +
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
            labs(title = "Monthly Salary") +
            geom_text(aes(label = paste0("$",prettyNum(round(month_sal,2),big.mark = ",")), y = month_sal + 50), size = 4, fontface = "bold") +
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
            mutate(monthly_remainder = ((salary/365) * 30.5) - expenses) %>%
            ggplot(., aes(x = city, y = monthly_remainder, label = monthly_remainder)) +
            geom_bar(stat = "identity",  fill = "steelblue4") +
            labs(title = "Remaining Monthly Income") +
            geom_text(aes(label = paste0("$",prettyNum(round(monthly_remainder,2), big.mark = ",")), y = monthly_remainder + 50), size = 4, fontface = "bold") +
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



