<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Shop Approved</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px; }
        .container { background-color: white; padding: 30px; border-radius: 10px; max-width: 600px; margin: 0 auto; }
        .status { font-size: 24px; font-weight: bold; color: #27ae60; margin-top: 20px; }
        .footer { margin-top: 30px; font-size: 12px; color: #888; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Your Shop Has Been Approved</h2>
        <p>Hello {{ $user_name }},</p>
        <p>Congratulations! Your shop <strong>{{ $shop_name }}</strong> has been approved and is now live on our platform.</p>
        <div class="status">
            Status: Approved
        </div>
        <p>You can now start adding products and managing your shop.</p>
        <div class="footer">
            &copy; {{ date('Y') }} Dbug Station Limited. All rights reserved.
        </div>
    </div>
</body>
</html>
