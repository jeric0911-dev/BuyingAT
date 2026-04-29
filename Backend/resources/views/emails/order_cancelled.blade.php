<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Order Cancelled</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px; }
        .container { background-color: white; padding: 30px; border-radius: 10px; max-width: 600px; margin: 0 auto; }
        .status { font-size: 24px; font-weight: bold; color: #e74c3c; margin-top: 20px; }
        .footer { margin-top: 30px; font-size: 12px; color: #888; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Order Cancelled</h2>
        <p>Hello {{ $user_name }},</p>
        <p>We’re sorry to inform you that your order <strong>#{{ $order_id }}</strong> has been cancelled.</p>
        <div class="status">
            Status: Cancelled
        </div>
        <p>If you have any questions or need further assistance, feel free to contact our support team.</p>
        <div class="footer">
            &copy; {{ date('Y') }} Dbug Station Limited. All rights reserved.
        </div>
    </div>
</body>
</html>
