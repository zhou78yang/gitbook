# 多阶段构建

参考文档：https://docs.docker.com/develop/develop-images/multistage-build/

将所有的构建过程编包含在一个`Dockerfile`中，包括项目及其依赖库的编译、 测试、打包等流程，这里可能会带来的一些问题： 
* `Dockerfile`特别长，可维护性降低 
* 镜像层次多，镜像体积较大，部署时间变长 
* 源代码存在泄露的风险

可以在Dockerfile中使用多个FROM语句实现多阶段构建，每个FROM指令都可以使用不同的镜像，从当前镜像开始构建的新阶段。

以下是一个前端项目Dockerfile

```bash
# build stage
FROM node:10.15.3 as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install -g cnpm --registry=https://registry.npm.taobao.org && cnpm install
COPY . .
RUN npm run build

# production stage
FROM nginx:stable as production-stage
COPY --from=build-stage /app/dist /usr/share/nginx/html
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

```

## 只构建某一阶段的镜像 
可以使用`as`来为某一阶段命名，例如`FROM node:10.15.3 as build-stage`，当我们只想构建`build-stage`阶段的镜像时，可以在使用`docker build`命令时加上`--target`参数即可。
```bash
$ docker build --target build-stage -t fe-build:latest .
```