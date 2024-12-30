import axios from "axios";

const model = {
  async get() {
    const result = await axios.get("/api/keywords");
    console.log("edit33dd2dddddddddddddddddddddddddddddddd");
    return result.data;
  },
};

export default model;
