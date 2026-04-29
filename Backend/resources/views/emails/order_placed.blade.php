<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Order Placed</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px; }
        .container { background-color: white; padding: 30px; border-radius: 10px; max-width: 600px; margin: 0 auto; }
        .status { font-size: 24px; font-weight: bold; color: #2980b9; margin-top: 20px; }
        .footer { margin-top: 30px; font-size: 12px; color: #888; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Order Successfully Placed</h2>
        <p>Hello {{ $user_name }},</p>
        <p>Thank you for your order! Your order <strong>#{{ $order_id }}</strong> has been successfully placed.</p>
        <div class="status">
            Status: Order Placed
        </div>
        <p>You will receive another email once your order is confirmed.</p>
        <div class="footer">
            &copy; {{ date('Y') }} Dbug Station Limited. All rights reserved.
        </div>
    </div>
</body>
</html>
