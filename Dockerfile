FROM node:20-alpine

WORKDIR /app

ENV PORT=3030

COPY app/package*.json ./

RUN npm install

COPY  app/ .

EXPOSE 3030

CMD ["npm", "start"]
