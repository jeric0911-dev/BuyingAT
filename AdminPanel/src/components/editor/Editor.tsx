import ReactQuill from "react-quill";
import "react-quill/dist/quill.snow.css";

type TProps = {
  fullDescription: string;
  setFullDescription: React.Dispatch<React.SetStateAction<string>>;
};

const Editor = ({ fullDescription, setFullDescription }: TProps) => {
  const modules = {
    toolbar: [
      [{ size: [] }],
      [{ header: [1, 2, 3, 4, 5, 6, false] }],
      ["bold", "italic", "underline", "strike", "blockquote", "code-block"],
      [{ color: [] }, { background: [] }],
      [{ script: "sub" }, { script: "super" }],
      [
        { list: "ordered" },
        { list: "bullet" },
        { indent: "-1" },
        { indent: "+1" },
      ],
      [{ align: [] }, { direction: "rtl" }],
      ["link", "image"],
      ["clean"],
    ],
    clipboard: {
      matchVisual: false,
    },
  };

  const formats = [
    "header",
    "font",
    "size",
    "bold",
    "italic",
    "underline",
    "strike",
    "blockquote",
    "code-block",
    "color",
    "background",
    "script",
    "list",
    "bullet",
    "indent",
    "align",
    "direction",
    "link",
    "image",
    "clean",
  ];

  return (
    <ReactQuill
      theme="snow"
      value={fullDescription}
      onChange={setFullDescription}
      modules={modules}
      formats={formats}
    />
  );
};

export default Editor;
