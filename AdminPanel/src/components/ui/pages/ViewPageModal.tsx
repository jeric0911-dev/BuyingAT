import { TPage } from "../../../types";
import RCModal from "../../modal/RCModal";

type TProps = {
  open: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
  data: TPage;
};

const ViewPageModal = ({ data, open, setOpen }: TProps) => {
  return (
    <RCModal open={open} setOpen={setOpen} maxWidth="md" title={data.title}>
      <p>Title: {data.title}</p>
      <div dangerouslySetInnerHTML={{ __html: data.content }}></div>
    </RCModal>
  );
};

export default ViewPageModal;
