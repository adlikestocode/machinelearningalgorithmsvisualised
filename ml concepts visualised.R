library(plotly())
# Use built-in iris dataset
iris <- iris
print(iris)

# Fit the linear regression model
model <- lm(Petal.Length ~ Sepal.Length, data = iris)

# View the coefficients of the model (intercept and slope)
print(coefficients(model))

# Check for missing values
if (any(is.na(iris$Sepal.Length)) || any(is.na(iris$Petal.Length))) {
  print("Warning: Missing values found in the data.")
}

# Extract data (assuming no missing values)
x <- iris$Sepal.Length
y <- iris$Petal.Length
# Generate predictions using the model
predictions <- predict(model, newdata = iris)

# Normalize features (optional, but can improve stability)
x_normalized <- scale(x)
y_normalized <- scale(y)

# 1. Data for 3D surface plot of the cost function
cost_function <- function(theta0, theta1, x, y) {
  predictions <- theta0 + theta1 * x
  squared_errors <- (predictions - y)^2
  if (any(is.nan(squared_errors))) {
    return(NA)
  } else {
    return(mean(squared_errors))
  }
}

# Create a grid of theta0 and theta1 values
theta0_values <- seq(-5, 5, length.out = 100)  # Adjusted range for normalized data
theta1_values <- seq(-5, 5, length.out = 100)

# Calculate cost function values for each combination of theta0 and theta1
cost_matrix <- outer(theta0_values, theta1_values,
                     Vectorize(function(t0, t1) cost_function(t0, t1, x_normalized, y_normalized)))
print(cost_matrix)
persp(cost_matrix)

# 2. Data for 2D heatmap of the cost function with gradient descent path
gradient_descent <- function(x, y, learning_rate = 0.01, iterations = 100) {
  theta0 <- 0
  theta1 <- 0
  history <- data.frame(iteration = integer(), theta0 = double(), theta1 = double(), cost = double())
  
  for (i in 1:iterations) {
    predictions <- theta0 + theta1 * x
    error <- predictions - y
    cost <- mean(error^2)
    history <- rbind(history, data.frame(iteration = i, theta0 = theta0, theta1 = theta1, cost = cost))
    
    # Gradients
    grad_theta0 <- mean(error)
    grad_theta1 <- mean(error * x)
    
    # Update parameters
    theta0 <- theta0 - learning_rate * grad_theta0
    theta1 <- theta1 - learning_rate * grad_theta1
    
    # Print cost, theta0, and theta1 at each iteration
    cat("Iteration:", i, "Cost:", cost, "Theta0:", theta0, "Theta1:", theta1, "\n")
  }
  return(history)
}

# Perform gradient descent
gd_history <- gradient_descent(x_normalized, y_normalized)
print(gd_history)


# 3. Data for 2D graph showing algorithm performance
performance_data <- data.frame(actual = y, predicted = predictions)

# Print the dataframes instead of writing to csv
print("Cost Function Data:")
print(cost_matrix)
persp(cost_matrix)#basicplot of cost function 

#using plotly to make a 3d volcano plot

# Assuming your cost_matrix is correctly defined 

# Create a data frame with x, y coordinates
x <- seq_along(1:ncol(cost_matrix))  # Assuming columns represent theta1 values
y <- seq_along(1:nrow(cost_matrix))  # Assuming rows represent theta0 values

# Create the 3D surface plot using persp()
persp(x, y, cost_matrix, 
      xlab = "Theta1", 
      ylab = "Theta0", 
      zlab = "Cost", 
      theta = 90, 
      phi = 10, 
      col = "lightblue") 

# Create a data frame with x, y coordinates
x <- seq_along(1:ncol(cost_matrix))  # Assuming columns represent theta1 values
y <- seq_along(1:nrow(cost_matrix))  # Assuming rows represent theta0 values
df <- expand.grid(x = x, y = y) 
df$z <- as.vector(t(cost_matrix))




print(cost_matrix)




# Assuming your cost_matrix is defined as shown in the previous responses

# Create the 3D surface plot using plotly
gradient <- plot_ly(z = ~t(cost_matrix), type = "surface", 
               colorscale = "Viridis", 
               reversescale = TRUE, 
               contours = list(
                 x = list(show = TRUE, start = min(1:ncol(cost_matrix)), end = max(1:ncol(cost_matrix)), size = 1),  # Adjust size for desired number of contours
                 y = list(show = TRUE, start = min(1:nrow(cost_matrix)), end = max(1:nrow(cost_matrix)), size = 1) 
               ),
               opacity = 0.8, 
              
) 

# Customize the plot (optional)
gradient<-gradient %>% layout(title = "Cost Function Surface",
                      scene = list(
                        xaxis = list(title = "Theta1"), 
                        yaxis = list(title = "Theta0"), 
                        zaxis = list(title = "Cost")),
                      showlegend= FALSE)

# Display the plot
gradient
# Load necessary libraries
library(plotly)

# Define the Cost Function and Gradients
cost_function <- function(theta0, theta1) {
  theta0^2 + theta1^2
}

grad_theta0 <- function(theta0, theta1) {
  2 * theta0
}

grad_theta1 <- function(theta0, theta1) {
  2 * theta1
}

# Gradient Descent Parameters
learning_rate <- 0.1
iterations <- 50
theta0 <- numeric(iterations)
theta1 <- numeric(iterations)
cost <- numeric(iterations)

# Initial values of theta
theta0[1] <- runif(1, -1, 1)
theta1[1] <- runif(1, -1, 1)
cost[1] <- cost_function(theta0[1], theta1[1])

# Perform Gradient Descent
for (i in 2:iterations) {
  theta0[i] <- theta0[i-1] - learning_rate * grad_theta0(theta0[i-1], theta1[i-1])
  theta1[i] <- theta1[i-1] - learning_rate * grad_theta1(theta0[i-1], theta1[i-1])
  cost[i] <- cost_function(theta0[i], theta1[i])
}

# Create a data frame for the gradient path
grad_path <- data.frame(
  iteration = 1:iterations,
  theta0 = theta0,
  theta1 = theta1,
  cost = cost
)

# Heatmap Grid
theta0_grid <- seq(-1, 1, length.out = 100)
theta1_grid <- seq(-1, 1, length.out = 100)
cost_matrix <- outer(theta0_grid, theta1_grid, cost_function)

# Create the Heatmap
heatmap_plot <- plot_ly(
  x = theta0_grid,
  y = theta1_grid,
  z = cost_matrix,
  type = "heatmap",
  colorscale = "Viridis"
)

# Add Animated Path with Static Heatmap
animated_plot <- heatmap_plot %>%
  add_trace(
    data = grad_path,
    x = ~theta0,
    y = ~theta1,
    frame = ~iteration,  # Use 'iteration' for animation frames
    type = 'scatter',
    mode = 'lines+markers',
    line = list(color = 'black', width = 2),
    marker = list(size = 6, color = ~cost, colorscale = 'Inferno')
  ) %>%
  layout(
    title = "Gradient Descent Path Animation",
    xaxis = list(title = "Theta0"),
    yaxis = list(title = "Theta1"),
    updatemenus = list(
      list(
        type = "buttons",
        showactive = FALSE,
        buttons = list(
          list(label = "Play",
               method = "animate",
               args = list(NULL, list(frame = list(duration = 100, redraw = FALSE)))),
          list(label = "Pause",
               method = "animate",
               args = list(NULL, list(frame = list(duration = 0, redraw = FALSE))))
        )
      )
    )
  ) %>%
  animation_opts(
    frame = 200,
    transition = 50,
    redraw = TRUE
  )
animated_plot
# Load necessary libraries
library(plotly)

# Load the Iris dataset
data(iris)

# Fit a linear model: Predict Sepal.Length from Petal.Length (you can choose other features as well)
lm_model <- lm(Sepal.Length ~ Petal.Length, data = iris)

# Get the actual and predicted values
actual_values <- iris$Sepal.Length
predicted_values <- predict(lm_model)

# Create the plotly plot
plot <- plot_ly() %>%
  # Actual values as scatter points
  add_markers(
    x = iris$Petal.Length, y = actual_values, 
    name = 'Actual',
    marker = list(color = 'blue', size = 8)
  ) %>%
  # Predicted values as a line (sorted for smooth line)
  add_lines(
    x = sort(iris$Petal.Length), 
    y = predicted_values[order(iris$Petal.Length)], 
    name = 'Predicted', 
    line = list(color = 'red')
  ) %>%
  layout(
    title = "Linear Regression: Actual vs Predicted Values (Iris Dataset)",
    xaxis = list(title = "Petal Length"),
    yaxis = list(title = "Sepal Length")
  )

# Display the plot
plot


