<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Shop Creation Request</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px; }
        .container { background-color: white; padding: 30px; border-radius: 10px; max-width: 600px; margin: 0 auto; }
        .status { font-size: 24px; font-weight: bold; color: #f39c12; margin-top: 20px; }
        .footer { margin-top: 30px; font-size: 12px; color: #888; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Shop Creation Request Received</h2>
        <p>Hello {{ $user_name }},</p>
        <p>We have received your request to create a shop: <strong>{{ $shop_name }}</strong>.</p>
        <div class="status">
            Status: Under Review
        </div>
        <p>Our team will review your request and notify you once it's approved.</p>
        <div class="footer">
            &copy; {{ date('Y') }} Dbug Station Limited. All rights reserved.
        </div>
    </div>
</body>
</html>
