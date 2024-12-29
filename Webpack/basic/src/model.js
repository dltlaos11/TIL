import axios from "axios";

const model = {
  async get() {
    const result = await axios.get("/api/keywords");
    return result.data;
  },
};

export default model;
