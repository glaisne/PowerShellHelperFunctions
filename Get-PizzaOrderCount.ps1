function get-PizzaOrderCount
{

<#
.SYNOPSIS
	Determines the number of pizzas to order
.DESCRIPTION
	Uses a proprietery method of high order math to 
	determine the exact number of pizzas to order 
	for any size group.
.EXAMPLE
	Get-PizzaOrderCount -GuestCount 50

	This example will determine the exact number 
	of pizzas for a group of 50 adults.
.PARAMETER GuestCount
	The number of guests who will be eating pizza.
#>
	[CmdletBinding(SupportsShouldProcess=$true)]
	param(
		[Parameter(Mandatory=$true)]
		[int] $GuestCount
	)

	[int] $(1 + (3 * ($GuestCount / 8)))

}