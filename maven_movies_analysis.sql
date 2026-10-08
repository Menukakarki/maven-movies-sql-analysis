use mavenmovies;

select *from customer;
select *from rental;
select *from film;

-- Display the names of customers who have rented more movies than the average number of rentals made by all customers.

with customer_rentals as
(select c.first_name, c.last_name, count(rental_id) as rental_count from customer c join rental r on r.customer_id=c.customer_id group by c.first_name, c.last_name)
select *from customer_rentals where rental_count > (select avg(rental_count) from customer_rentals);

-- Display each film along with its rental rate and assign a rank based on rental rate from highest to lowest.
select title, rental_rate, dense_rank() over(order by rental_rate desc)as renta_rate_rank from film;

-- Create a view that displays customer names along with their email and active status. 
create view customer_info as 
select first_name, email, active as active_status from customer;
select *from customer_info;

-- Find the top 10 customers who generated the highest payment amount.
select *from payment;
select *from rental;
select *from customer;
select c.first_name ,sum(p.amount) from customer c join payment p on p.customer_id = c.customer_id group by c.first_name  order by sum(p.amount) desc limit 10;

-- Identify the customers whose total spending on rentals falls within the top 20% of all customers.
with top20 as
(select c.first_name ,sum(p.amount) as total_spending from customer c join payment p on p.customer_id = c.customer_id group by c.first_name)
select *from (select *, ntile(5) over (order by total_spending desc)as spending_group from top20) as ranked_customers where spending_group=1;

-- Display every actor along with the number of movies they acted in and assign Dense Rank based on movie count.
select *from actor;
select *from film_actor;
select *from film;
 
select *, dense_rank() over(order by movie_count desc) as movie_rank from(
select a.first_name, a.last_name, count(f.title) as movie_count from actor a join film_actor fa on fa.actor_id = a.actor_id 
join film f on fa.film_id =f.film_id group by a.first_name, a.last_name, a.actor_id) as count_rank ;


select *from film;
select *from film_category;
select *from category;
-- Create a view showing movie title, category, rental rate and replacement cost.
create view movie_info as 
select f.title, c.name, f.rental_rate, f.replacement_cost from film f join film_category fc on fc.film_id =f.film_id 
join category c on fc.category_id = c.category_id;

select *from movie_info;


-- Create a stored procedure that returns the top 20 most rented movies.
select *from inventory;
select *from rental;
select *from film;

delimiter //
create procedure rented_movie()
begin 
select f.title, count(r.rental_id) from film f join inventory i on i.film_id = f.film_id 
join rental r on r.inventory_id = i.inventory_id group by f.title order by count(r.rental_id) desc limit 20;
end //
delimiter ;
call rented_movie();

-- Create a procedure that accepts a movie rating and returns all movies of that rating.
select distinct rating from film;
delimiter //
create procedure rating_movie(in movie_rating varchar(8))
begin 
select title, rating from film where rating = movie_rating ;
end //
delimiter ;
call rating_movie('PG');

select *from category;
select *from film;
select *from film_category;
select *from inventory;

-- Identify the top 3 films in each category based on their rental counts.
with top_3 as (
select f.title, count(r.rental_id) as rental_count, c.name as category_name from rental r 
join inventory i on r.inventory_id = i.inventory_id 
join film f on i.film_id = f.film_id 
join film_category fc on fc.film_id = f.film_id 
join category c on fc.category_id = c.category_id group by c.name, f.title),
ranked_film as (
select *, dense_rank() over(partition by category_name order by rental_count desc)as film_rank from top_3)
select *from ranked_film where film_rank<=3;


-- Calculate the running total of rentals per category, ordered by rental count.
select c.name as category_name,
count(r.rental_id) as rental_count, 
sum(count(r.rental_id)) over (order by count(rental_id))as running_total 
from rental r 
join inventory i on r.inventory_id = i.inventory_id 
join film f on i.film_id = f.film_id 
join film_category fc on fc.film_id = f.film_id 
join category c on fc.category_id = c.category_id 
group by c.name; 


-- Create a CTE to generate a report showing pairs of actors who have appeared in the same film together, using the film_actor table
select *from film_actor;
select *from film;
select *from actor;

with actor_pair as (
select table1.film_id, table1.actor_id as actor1, table2.actor_id as actor2 
from film_actor table1 inner join film_actor table2 on table1.film_id = table2.film_id and table1.actor_id < table2.actor_id)
select *from actor_pair;
 
-- Create a procedure that accepts a customer ID as input and returns the customer's total payment as an output parameter   
select *from payment;
delimiter //
create procedure customer_payment
(in customer_id_in int, out total_payment decimal(10,2))
begin 
select sum(amount) into total_payment 
from payment 
where customer_id = customer_id_in ;
end //
delimiter ;

call customer_payment(7,@result);

select @result;
