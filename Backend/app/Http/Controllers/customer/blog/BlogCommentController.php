<?php

namespace App\Http\Controllers\customer\blog;

use App\Http\Controllers\BaseController;
use App\Models\BlogComment;
use Illuminate\Http\Request;
use App\Services\ResponseService;

class BlogCommentController extends BaseController
{
    // Store comment
    public function store(Request $request)
    {
        $data = $request->validate([
            'blog_id' => 'required|exists:blogs,id',
            'comment' => 'required|string',
        ]);

        $data['user_id'] = $request->user()->id;

        $blogComment = BlogComment::create($data);

        return $this->sendSuccessResponse('Comment created successfully', $blogComment);
    }

    // Update comment
    public function update(Request $request, $id)
    {
        $blogComment = BlogComment::findOrFail($id);

        $data = $request->validate([
            'blog_id' => 'nullable|exists:blogs,id',
            'comment' => 'nullable|string',
        ]);

        $blogComment->update($data);

        return $this->sendSuccessResponse('Comment updated successfully', $blogComment);
    }

    // Delete comment
    public function destroy($id)
    {
        $blogComment = BlogComment::findOrFail($id);
        $blogComment->delete();

        return $this->sendSuccessResponse('Comment deleted successfully');
    }
}
